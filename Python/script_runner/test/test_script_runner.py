# third-party
import twisted.trial.unittest as unittest
import twisted.internet.defer as defer
import twisted.internet.base as base
import twisted.internet.reactor as reactor
import twisted.python.failure as failure
import xml.dom.minidom as minidom
import re as re
import time as time
import yaml as yaml

# product
import mir.script_runner.script_runner as sr
import mir.script_runner.test.db as testdb
import mir.script_runner.test.xmlrpcproxy as testindexer
import mir.models as models
import mir.log_service as log_service
import mir.identity as identity
import mir.config as config
import mandiant.windtalker.message_bus_injector as mbus_factory
import mir.util.dtutil as mir_datetime
import mir.script_runner.execution_node as en

config_data = config.MirConfig("mir")
# add configs for services we use
config_data.loadServiceConfig('agentcontroller')
config_data.loadServiceConfig('fileserver')
config_data.loadServiceConfig('search')
config_data.loadServiceConfig('scriptrunner')
config_data.loadServiceConfig('analyzer')
config_data.loadServiceConfig('scheduler')

base.DelayedCall.debug = True

class ScriptRunnerTests(unittest.TestCase):
    timeout = 5                # Set a default timeout
    script_runner = None
    
    def __init__(self, test_to_run):
        unittest.TestCase.__init__(self, test_to_run)
        self.mbus = mbus_factory.MessageBusTestInjectorFactory("script_runner")
        
    def setUp(self):
        self.database = "/usr/lib/python2.5/site-packages/mir/script_runner/test/"
        
    
    def _setUp(self, scriptfile="implicit_chaining_1.xml"):
        self.job_script = file(self.database + "data/job_scripts/%s" % scriptfile).read()
        
        self.job_schedule = "now"
        
        self.job_input_uri_list = "<input><uri>/workspaces/1/hosts/resources/1/</uri>\n<uri>/workspaces/1/hosts/resources/2/</uri></input>"
        
        self.job_xml = '%s%s\n<when>%s</when>\n%s\n</JobDefinition>' % (
                     '<?xml version="1.0"?>\n<JobDefinition xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" href="/workspaces/1/jobs/234/">',
                     re.sub(r'^<\?[^\?]+\?>', '', self.job_script),
                     re.sub(r'^<\?[^\?]+\?>', '', self.job_schedule),
                     re.sub(r'^<\?[^\?]+\?>', '', self.job_input_uri_list),
                  )
        
        self.script_runner = sr.ScriptRunner(db=False, indexer=False, mbus=self.mbus, testing=True)
        self.script_runner.db = testdb.ACTestObjectDB(scriptfile=scriptfile)
        self.session = self.script_runner.db.session
        self.script_runner.indexer = testindexer.ACTestIndexer()
        
        self.t_job = models.Job("ScriptRunner TestJob #1", schedule=self.job_schedule, input=self.job_input_uri_list, script=self.job_script, workspace_id=1, id=14)
        self.t_res = models.ResultSet(name="%s Results Container @ %s" % (self.t_job.name, mir_datetime.strISO_now()), job=self.t_job, workspace_id=self.t_job.workspace_id)
        self.t_job.results.append(self.t_res)
        self.t_res.status = models.Status("Status for ResultSet %s" % self.t_res.id, activity='Starting', state='pending', status=None, id=self.t_res.id)
        
        job_rec = {
           'job_obj': self.t_job, 
           'result': self.t_res,
           'job_identity': self.t_job.href,
           'job_script': self.t_job.script,
           'job_url': str(identity.identity_from_string(self.t_job.href)),
           'script_dom': minidom.parseString(self.job_script),
           'workspace_id': 1,
           'input': self.t_job.input,
           'job_elem': minidom.parseString('<?xml version="1.0" encoding="utf-8"?>%s' % self.t_job.dump_job_manifest()),
           'executionMetaData': minidom.parseString('<?xml version="1.0" encoding="utf-8"?>%s' % self.t_res.dump_execution_manifest()),
        }
        
        self.job_rec = job_rec
    


    def testCreateNewJobMessage(self):
        import mir.scheduler.scheduler as scheduler
        self._setUp()
        
        xx = scheduler.Scheduler()
        msg = xx.createNewJobMessage(self.t_job)
        
        self.assertEqual(type(msg), dict)
        
        self.assertEqual(msg['new_job_id'], self.t_job.href)
        del(msg['new_job_id'])
        
        self.assertEqual(len(msg), 0)
        
        
        
    def testWebInfRender(self):
        import mir.script_runner.service as service

        self.timeout = 5
        self._setUp(scriptfile="basic_agent_1.xml")

        job_ident = identity.Identity(workspace=1, type='Job', object_id=14)
        
        class bogusRequest(object):
            
            def __init__(self, path="/", args={}):
                self.path = path
                self.args = args
        
                
        newreq = bogusRequest(path='/newjob', args={'jobhref': [str(job_ident)]})
        
        self.assertEqual(newreq.path, "/newjob")
        self.assertEqual(newreq.args["jobhref"][0], str(job_ident))
        self.assertEqual(len(self.script_runner.active_jobs), 0)
        
        xx = service.ScriptRunnerWebInterface(self.script_runner)
        self.script_runner.testing = True

        retval = yield xx.render(newreq)
        
        self.assertEqual(len(self.script_runner.active_jobs), 1)
        self.assertIn(str(job_ident), self.script_runner.active_jobs.keys())
        self.assertEqual(self.script_runner.active_jobs[str(job_ident)]['job_obj'].id, 14)
        
        
    testWebInfRender = defer.inlineCallbacks(testWebInfRender)   
    

    def testWebInfInit(self):
        import mir.script_runner.service as service
        
        xx = service.ScriptRunnerWebInterface(self.script_runner)
        
        self.assertIdentical(xx.script_runner, self.script_runner)
        self.assertEqual(xx.debug_level, 0)
        
        xx = service.ScriptRunnerWebInterface(self.script_runner, debug_level=5)

        self.assertIdentical(xx.script_runner, self.script_runner)
        self.assertEqual(xx.debug_level, 5)
        
        

    def testReceiveJobResults(self):
        self.timeout = 5
        self._setUp()
        
        job_input_doc = minidom.parseString(self.job_xml)
        jd_job = job_input_doc.getElementsByTagName('JobDefinition')[0]
        jd_script = jd_job.getElementsByTagName('script')[0]
        
        ww = en.ExecutionNode(config_data=config_data, command='Script', name='S0', chaining="implicit")
        ww.outputMap = {
            '/workspaces/1/documents/all/21/': '/workspaces/1/hosts/all/01/',
            '/workspaces/1/documents/all/20/': '/workspaces/1/hosts/all/07/',
            '/workspaces/1/documents/all/22/': '/workspaces/1/hosts/all/07/',
            '/workspaces/1/documents/all/24/': '/workspaces/1/hosts/all/27/',
            '/workspaces/1/documents/all/26/': '/workspaces/1/hosts/all/27/',
            '/workspaces/1/documents/all/27/': '/workspaces/1/hosts/all/47/',
            '/workspaces/1/documents/all/23/': '/workspaces/1/hosts/all/47/',
            '/workspaces/1/documents/all/25/': '/workspaces/1/hosts/all/47/',
        }
        ww.allInputsReceived = True
        ww.allOutputsSent = True

        result = self.job_rec['result']
        result.status.status = '27% Complete'
        result.status.state = 'running'
        result.status.activity = 'Executing'
        result.status.starttime = mir_datetime.strISO_now()
        result.status.stoptime = None
        self.job_rec['documents'] = {}
        
        self.assertEqual(self.job_rec.has_key('manifest'), False)
        self.assertEqual(result.manifest, None)
        self.assertEqual(result.status.state, "running")
        self.assertEqual(result.status.status, "27% Complete")
        self.assertEqual(result.status.activity, "Executing")
        self.assertEqual(type(self.job_rec['documents']), dict)
        self.assertEqual(len(self.job_rec['documents']), 0)

        self.job_rec['base_execution_node'] = ww

        yield self.script_runner.receiveJobResults(None, ww, self.job_rec)
        
        self.session.update(result)
        
        self.assertEqual(type(self.job_rec['documents']), dict)
        self.assertEqual(len(self.job_rec['documents']), 1)
        self.assertIdentical(self.job_rec['documents'].values()[0], self.job_rec['manifest'])
        
        manifest_doc = self.job_rec['manifest']
        
        self.assertIdentical(self.job_rec['manifest'], self.job_rec['result'].manifest)

        #print manifest_doc.toxml('utf-8')
        
        self.assertEqual(result.status.state, "complete")
        self.assertEqual(result.status.status, "100% Complete")
        self.assertEqual(result.status.activity, "Complete")
        self.assertEqual(result.status.stoptime != None, True)
        self.assertEqual(result.status.starttime != None, True)

    testReceiveJobResults = defer.inlineCallbacks(testReceiveJobResults)    

        
        
    def testCreateManifest_1(self):
        self.timeout = 5
        self._setUp()
        
        job_input_doc = minidom.parseString(self.job_xml)
        jd_job = job_input_doc.getElementsByTagName('JobDefinition')[0]
        jd_script = jd_job.getElementsByTagName('script')[0]
        
        # build outputMap for job_rec['base_execution_node']
        
        manifest_doc = self.script_runner.createManifest(self.job_rec)
        #print manifest_doc.toxml('utf-8')
        job = manifest_doc.getElementsByTagName('JobDefinition')[0]
        script = job.getElementsByTagName('script')[0]
        
        self.assertEqual(len(manifest_doc.getElementsByTagName('JobDefinition')), 1)
        self.assertEqual(len(manifest_doc.getElementsByTagName('JobDefinition')), len(job_input_doc.getElementsByTagName('JobDefinition')))
        self.assertEqual(len(job.getElementsByTagName('script')), len(jd_job.getElementsByTagName('script')))
        self.assertEqual(len(job.getElementsByTagName('when')), len(jd_job.getElementsByTagName('when')))
        self.assertEqual(len(job.getElementsByTagName('input')), len(jd_job.getElementsByTagName('input')))
        self.assertEqual(len(script.getElementsByTagName('command')), len(jd_script.getElementsByTagName('command')))
        self.assertEqual(len(script.getElementsByTagName('result')), len(jd_script.getElementsByTagName('result')))
        
        self.assertEqual(len(manifest_doc.getElementsByTagName('JobResults')), 1)
        self.assertEqual(len(manifest_doc.getElementsByTagName('JobExecutionMetaData')), 1)
        
        
        
    def testCreateManifest_2(self):
        self.timeout = 5
        self._setUp()
        
        job_input_doc = minidom.parseString(self.job_xml)
        jd_job = job_input_doc.getElementsByTagName('JobDefinition')[0]
        jd_script = jd_job.getElementsByTagName('script')[0]
        
        ww = en.ExecutionNode(config_data=config_data, command='Script', name='S0', chaining="implicit")
        ww.outputMap = {
            '/workspaces/1/documents/all/21/': '/workspaces/1/hosts/all/01',
            '/workspaces/1/documents/all/20/': '/workspaces/1/hosts/all/07',
            '/workspaces/1/documents/all/22/': '/workspaces/1/hosts/all/07',
            '/workspaces/1/documents/all/24/': '/workspaces/1/hosts/all/27',
            '/workspaces/1/documents/all/26/': '/workspaces/1/hosts/all/27',
            '/workspaces/1/documents/all/27/': '/workspaces/1/hosts/all/47',
            '/workspaces/1/documents/all/23/': '/workspaces/1/hosts/all/47',
            '/workspaces/1/documents/all/25/': '/workspaces/1/hosts/all/47',
        }
        ww.allInputsReceived = True
        ww.allOutputsSent = True
        
        self.job_rec['base_execution_node'] = ww
        
        manifest_doc = self.script_runner.createManifest(self.job_rec, ww)
        #print manifest_doc.toxml('utf-8')
        job = manifest_doc.getElementsByTagName('JobDefinition')[0]
        script = job.getElementsByTagName('script')[0]
        
        self.assertEqual(len(manifest_doc.getElementsByTagName('JobDefinition')), 1)
        self.assertEqual(len(manifest_doc.getElementsByTagName('JobDefinition')), len(job_input_doc.getElementsByTagName('JobDefinition')))
        self.assertEqual(len(job.getElementsByTagName('script')), len(jd_job.getElementsByTagName('script')))
        self.assertEqual(len(job.getElementsByTagName('when')), len(jd_job.getElementsByTagName('when')))
        self.assertEqual(len(job.getElementsByTagName('input')), len(jd_job.getElementsByTagName('input')))
        self.assertEqual(len(script.getElementsByTagName('command')), len(jd_script.getElementsByTagName('command')))
        self.assertEqual(len(script.getElementsByTagName('result')), len(jd_script.getElementsByTagName('result')))
        
        self.assertEqual(len(manifest_doc.getElementsByTagName('JobResults')), 1)
        res_map = manifest_doc.getElementsByTagName('JobResults')[0]
        for mapnode in res_map.getElementsByTagName('MapNode'):
            outputNode = mapnode.getElementsByTagName('Output')[0].childNodes[0].nodeValue
            inputNode = mapnode.getElementsByTagName('Input')[0].childNodes[0].nodeValue
            
            self.assertEqual(ww.outputMap[outputNode], inputNode)
            
        self.assertEqual(len(manifest_doc.getElementsByTagName('JobExecutionMetaData')), 1)
        
        
        
    def testConfig(self):
        import mandiant.windtalker.payload as payload
        self.timeout = 5
        self._setUp()

        myconfigs = {'abc': 1}
        
        self.assertEqual(type(self.script_runner.configs), dict)
        self.assertEqual(len(self.script_runner.configs), 0)
        
        resmessage = {'configs': myconfigs}
        
        msg = payload.SimpleMessage(msgid=1,
                                    queue='abc',
                                    message=yaml.safe_dump(resmessage),
                                   )

        self.script_runner.config(msg)

        self.assertEqual(type(self.script_runner.configs), dict)
        self.assertEqual(len(self.script_runner.configs), 1)
        self.assertEqual(self.script_runner.configs['abc'], 1)
        
        myconfigs = {'abc': 1, 'def': 2, 'ghi': 3, 'klm': [1, 2, 3], 'nop': { 'a': 1, 'b': 2}, }
        resmessage = {'configs': myconfigs}
        
        msg = payload.SimpleMessage(msgid=1,
                                    queue='abc',
                                    message=yaml.safe_dump(resmessage),
                                   )

        self.script_runner.config(msg)

        self.assertEqual(type(self.script_runner.configs), dict)
        self.assertEqual(len(self.script_runner.configs), len(myconfigs))
        
        for config in myconfigs:
            self.assertIn(config, self.script_runner.configs.keys())
            if type(config) == list:
                for xx in myconfigs[config]:
                    self.assertIn(xx, self.script_runner.configs[config])
            elif type(config) == dict:
                for xx in myconfigs[config]:
                    self.assertIn(xx, self.script_runner.configs[config].keys())
                    self.assertEqual(myconfigs[config][xx], self.script_runner.configs[config][xx])
            else:
                self.assertEqual(myconfigs[config], self.script_runner.configs[config])
        
    
    def testConfig_2(self):
        self.timeout = 5
        self._setUp()
        
        myconfigs = {'abc': 1}
        
        self.assertEqual(type(self.script_runner.configs), dict)
        self.assertEqual(len(self.script_runner.configs), 0)
        
        resmessage = {'configs': myconfigs}

        def msgBack(message):
            pass
        
        self.mbus.add_queue(config_data.getByPath('scheduler', 'queues', 'configqueue'), msgBack)
        
        self.mbus.sendMessagetoQueue(config_data.getByPath('script_runner', 'queues', 'configqueue'), yaml.safe_dump(resmessage))
        
        self.assertEqual(type(self.script_runner.configs), dict)
        self.assertEqual(len(self.script_runner.configs), 1)
        self.assertEqual(self.script_runner.configs['abc'], 1)
    
        myconfigs = {'abc': 1, 'def': 2, 'ghi': 3, 'klm': [1, 2, 3], 'nop': { 'a': 1, 'b': 2}, }
        resmessage = {'configs': myconfigs}

        self.mbus.sendMessagetoQueue(config_data.getByPath('script_runner', 'queues', 'configqueue'), yaml.safe_dump(resmessage))
        
        self.assertEqual(type(self.script_runner.configs), dict)
        self.assertEqual(len(self.script_runner.configs), len(myconfigs))
        
        for config in myconfigs:
            self.assertIn(config, self.script_runner.configs.keys())
            if type(config) == list:
                for xx in myconfigs[config]:
                    self.assertIn(xx, self.script_runner.configs[config])
            elif type(config) == dict:
                for xx in myconfigs[config]:
                    self.assertIn(xx, self.script_runner.configs[config].keys())
                    self.assertEqual(myconfigs[config][xx], self.script_runner.configs[config][xx])
            else:
                self.assertEqual(myconfigs[config], self.script_runner.configs[config])

    
    def testInit(self):
        self.timeout = 10
        
        uri = config.uriForService(config_data, 'indexer')
        m = re.match(r'^http://(.*?)(:(\d+))?(/.*)$', uri)
        
        host = m.group(1)
        port = m.group(3)
        path = m.group(4)

        xx = sr.ScriptRunner(testing=True)
        
        self.assertEqual(xx.mbus, False)
        self.assertEqual(type(xx.db), models.db.MirObjectDB)
        self.assertEqual(xx.indexer.host, host)
        self.assertEqual(xx.indexer.port, (int)(port))
        self.assertEqual(xx.indexer.path, path.encode())
        self.assertEqual(type(xx.active_jobs), dict)
        self.assertEqual(len(xx.active_jobs), 0)
        self.assertEqual(xx.testing, True)
        self.assertEqual(xx.debug_level, 0)
        self.assertEqual(type(xx.configs), dict)
        self.assertEqual(len(xx.configs), 0)
        
        
        xx = sr.ScriptRunner(debug_level=4, mbus=False, db=False, indexer=False, testing=True, configs={'abc': 1})
        
        self.assertEqual(xx.debug_level, 4)
        self.assertEqual(xx.mbus, False)
        self.assertEqual(xx.db, False)
        self.assertEqual(xx.indexer, False)
        self.assertEqual(type(xx.active_jobs), dict)
        self.assertEqual(len(xx.active_jobs), 0)
        self.assertEqual(xx.testing, True)
        self.assertEqual(type(xx.configs), dict)
        self.assertEqual(len(xx.configs), 1)
        self.assertEqual(xx.configs['abc'], 1)

        xx = sr.ScriptRunner(debug_level=2, mbus=self.mbus, db=config_data.getByPath('dbconn'), testing=True)
        
        self.assertEqual(xx.debug_level, 2)
        self.assertIdentical(xx.mbus, self.mbus)
        self.assertIn(config_data.getByPath('script_runner', 'queues', 'basequeue'), xx.mbus.queues)
        self.assertIn(config_data.getByPath('script_runner', 'queues', 'newjobqueue'), xx.mbus.queues)
        self.assertIn(config_data.getByPath('script_runner', 'queues', 'configqueue'), xx.mbus.queues)
        self.assertIdentical(type(xx.db), models.MirObjectDB)
        self.assertEqual(xx.indexer.host, host)
        self.assertEqual(xx.indexer.port, (int)(port))
        self.assertEqual(xx.indexer.path, path.encode())
        self.assertEqual(type(xx.active_jobs), dict)
        self.assertEqual(len(xx.active_jobs), 0)
        self.assertEqual(type(xx.configs), dict)
        self.assertEqual(len(xx.configs), 0)
        

    def testGetSearchService(self):
        self._setUp()
        
        uri = config.uriForService(config_data, 'indexer')
        m = re.match(r'^http://(.*?)(:(\d+))?(/.*)$', uri)
        
        host = m.group(1)
        port = m.group(3)
        path = m.group(4)
        
        self.script_runner.indexer = False
        
        self.assertEqual(self.script_runner.indexer, False)
        
        self.script_runner.getSearchService()
        
        self.assertEqual(self.script_runner.indexer.host, host)
        self.assertEqual(self.script_runner.indexer.port, (int)(port))
        self.assertEqual(self.script_runner.indexer.path, path.encode())


    def testKickOffExecution(self):
        self.timeout = 5
        self._setUp()
        
        inputSet = [
            'abc', 'abc2', 'abc3', 'abc4',
        ]

        xx = en.ExecutionNode(config_data=config_data, command='Script', name='XX', chaining='implicit')

        def msgBack(outputSet, sourceNode, job_rec):
            self.madeItHere = True
            
            for i in inputSet:
                self.assertIn(i, outputSet)
            self.assertIdentical(sourceNode, xx)
                
        xx.requestInputSet(xx, xx.receiveOutputSet)

        self.job_rec['base_execution_node'] = xx
        self.job_rec['input_set'] = inputSet
        self.job_rec['job_ident'] = 'QQQQQQ'
        
        self.script_runner.active_jobs[self.job_rec['job_ident']] = self.job_rec
        
        self.script_runner.kickOffExecution(self.job_rec, msgBack, std_callbacks={'kickOffExecution': False})
        
        self.assertEqual(self.madeItHere, True)
        
        
    def testReportStatus_1(self):
        self.timeout = 5
        self._setUp()
        
        status_line = "50% Complete"
        job_name = 'xx'
        
        class xxClass(object):
            def reportStatus(self):
                return status_line
        
        self.assertEqual(status_line, xxClass().reportStatus())    
        self.assertEqual(len(self.script_runner.active_jobs), 0)
        self.assertEqual(self.t_res.status.state, 'pending')
        self.assertEqual(self.t_res.status.status, None)
        self.assertEqual(self.t_res.status.activity, 'Starting')
        
        self.script_runner.active_jobs[job_name] = {'base_execution_node': xxClass(), 'result': self.t_res}
        self.assertEqual(len(self.script_runner.active_jobs), 1)
        self.assertEqual(status_line, self.script_runner.active_jobs[job_name]['base_execution_node'].reportStatus())
        
        
        yield self.script_runner.reportStatus(std_callbacks={'reportStatus': False})
        
        self.assertEqual(len(self.script_runner.active_jobs), 1)
        self.assertEqual(status_line, self.script_runner.active_jobs[job_name]['base_execution_node'].reportStatus())
        
        self.assertEqual(self.t_res.status.state, 'running')
        self.assertEqual(self.t_res.status.status, status_line)
        self.assertEqual(self.t_res.status.activity, 'Executing')
    testReportStatus_1 = defer.inlineCallbacks(testReportStatus_1)    
        
        
    def testReportStatus_2(self):
        self.timeout = 5
        self._setUp()
        
        status_line = "100% Complete"
        job_name = 'xx'
        
        class xxClass(object):
            def reportStatus(self):
                return status_line
        
        self.assertEqual(status_line, xxClass().reportStatus())    
        self.assertEqual(len(self.script_runner.active_jobs), 0)
        self.assertEqual(self.t_res.status.state, 'pending')
        self.assertEqual(self.t_res.status.status, None)
        self.assertEqual(self.t_res.status.activity, 'Starting')
        
        self.script_runner.active_jobs[job_name] = {'base_execution_node': xxClass(), 'result': self.t_res}
        self.assertEqual(len(self.script_runner.active_jobs), 1)
        self.assertEqual(status_line, self.script_runner.active_jobs[job_name]['base_execution_node'].reportStatus())
        
        
        yield self.script_runner.reportStatus(std_callbacks={'reportStatus': False})
        
        self.assertEqual(len(self.script_runner.active_jobs), 0)
        
        self.assertEqual(self.t_res.status.state, 'complete')
        self.assertEqual(self.t_res.status.status, status_line)
        self.assertEqual(self.t_res.status.activity, 'Complete')
    testReportStatus_2 = defer.inlineCallbacks(testReportStatus_2)    
        
        
    def testReportStatus_3(self):
        self.timeout = 5
        self._setUp()
        
        status_lines = ["25% Complete", "30% Complete", "40% Complete"]
        
        class xxClass(object):
            def __init__(self, status_line):
                self.status_line = status_line
                
            def reportStatus(self):
                return self.status_line
        
        for status_line in status_lines:
            self.assertEqual(status_line, xxClass(status_line).reportStatus())   
             
        self.assertEqual(len(self.script_runner.active_jobs), 0)
        
        for status in status_lines:
            x_res = models.ResultSet(name="%s Results Container @ %s" % (self.t_job.name, mir_datetime.strISO_now()), job=self.t_job, workspace_id=self.t_job.workspace_id)
            self.t_job.results.append(x_res)
            self.session.save(x_res)
            self.session.update(x_res)
            x_res.status = models.Status("Status for ResultSet %s" % x_res.id, activity='Starting', state='pending', status=None, id=x_res.id)
            self.session.save(x_res)
            self.session.update(x_res)
            
            self.script_runner.active_jobs[status] = {'base_execution_node': xxClass(status), 'result': x_res}
            self.assertEqual(status, self.script_runner.active_jobs[status]['base_execution_node'].reportStatus())

            self.assertEqual(self.script_runner.active_jobs[status]['result'].status.state, 'pending')
            self.assertEqual(self.script_runner.active_jobs[status]['result'].status.status, None)
            self.assertEqual(self.script_runner.active_jobs[status]['result'].status.activity, 'Starting')
        
        self.session.save(self.t_job)
        self.session.flush()
        self.session.clear()

        self.assertEqual(len(self.script_runner.active_jobs), len(status_lines))
        
        yield self.script_runner.reportStatus(std_callbacks={'reportStatus': False})
        
        self.assertEqual(len(self.script_runner.active_jobs), len(status_lines))
        
        for status in status_lines:
            self.assertEqual(self.script_runner.active_jobs[status]['result'].status.state, 'running')
            self.assertEqual(self.script_runner.active_jobs[status]['result'].status.status, status)
            self.assertEqual(self.script_runner.active_jobs[status]['result'].status.activity, 'Executing')
    testReportStatus_3 = defer.inlineCallbacks(testReportStatus_3)    
        
        
    def testNewJob_2(self):
        self.timeout = 5
        self._setUp()
        
        def msgBack(message):
            pass
        
        self.mbus.add_queue(config_data.getByPath('scheduler', 'queues', 'basequeue'), msgBack)
        
        resmessage = {'new_job_id': self.t_job.href, 'std_callbacks': {"newJob": False}}
        
        self.mbus.sendMessagetoQueue(config_data.getByPath('script_runner', 'queues', 'newjobqueue'), yaml.safe_dump(resmessage))
        
        

    def testNewJob_1(self):
        import mandiant.windtalker.payload as payload

        self.timeout = 5
        self._setUp()
        
        resmessage = {'new_job_id': self.t_job.href, 'std_callbacks': {"newJob": False}}
        
        msg = payload.SimpleMessage(msgid=1,
                                    queue='abc',
                                    message=yaml.safe_dump(resmessage),
                                   )

        self.script_runner.newJob(msg)
        
        

    def testBuild_execution_tree(self):
        """
        Test Queue Management messages and errors
        """
        self.timeout = 5                # Set a reasonable timeout

        ######
        self._setUp()
        self.script_runner.build_execution_tree(self.job_rec, {"build_execution_tree": False})
        basenode = self.job_rec['base_execution_node']
        
        nodeMap = {}
        commandMap = {}
        
        for t_node in basenode.allnodes:
            nodeMap[t_node] = basenode.getNameByNodeID(t_node)
            commandMap[nodeMap[t_node]] = t_node

        #basenode.dumpNodeGraph()
        
        # Sup/Super    
        self.assertEqual(4, len(basenode.subcommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C1']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C2']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C4']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C3']).supercommands))
        self.assertEqual(0, len(basenode.supercommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C1']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C2']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C4']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C3']).subcommands))
        self.assertIn(commandMap['C1'], basenode.subcommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['C1']).supercommands)
        self.assertIn(commandMap['C2'], basenode.subcommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['C2']).supercommands)
        self.assertIn(commandMap['C4'], basenode.subcommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['C4']).supercommands)
        self.assertIn(commandMap['C3'], basenode.subcommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['C3']).supercommands)

        # Parent/Child
        self.assertEqual(0, len(basenode.parents))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C1']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C2']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C3']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C4']).parents))
        self.assertEqual(0, len(basenode.children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C1']).children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C2']).children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C3']).children))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C4']).children))
        self.assertIn(commandMap['C1'], basenode.getNodeByNodeID(commandMap['C2']).parents)
        self.assertIn(commandMap['C2'], basenode.getNodeByNodeID(commandMap['C3']).parents)
        self.assertIn(commandMap['C3'], basenode.getNodeByNodeID(commandMap['C4']).parents)
        self.assertIn(commandMap['C2'], basenode.getNodeByNodeID(commandMap['C1']).children)
        self.assertIn(commandMap['C3'], basenode.getNodeByNodeID(commandMap['C2']).children)
        self.assertIn(commandMap['C4'], basenode.getNodeByNodeID(commandMap['C3']).children)

        
        # InputListeners/OutputListeners
        self.assertEqual(0, len(basenode.inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C1']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C2']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C3']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C4']).inputItemListeners.keys()))
        self.assertEqual(1, len(basenode.inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C1']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C2']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C3']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C4']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C1']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C2']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C3']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C4']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C1']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C2']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C3']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C4']).outputSetListeners.keys()))
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['C4']).outputSetListeners.keys())
        self.assertIn(commandMap['C1'], basenode.getNodeByNodeID(commandMap['S0']).inputSetListeners.keys())
        self.assertIn(commandMap['C2'], basenode.getNodeByNodeID(commandMap['C1']).outputSetListeners.keys())
        self.assertIn(commandMap['C4'], basenode.getNodeByNodeID(commandMap['C3']).outputSetListeners.keys())
        self.assertIn(commandMap['C3'], basenode.getNodeByNodeID(commandMap['C2']).outputSetListeners.keys())
        
        
    def testInitiate(self):
        """
        Test Queue Management messages and errors
        """
        self.timeout = 5                # Set a reasonable timeout

        ######
        self._setUp()
        self.job_rec['job_obj'].results = []
        self.assertEqual(len(self.job_rec['job_obj'].results), 0)
        
        script_def = yield self.script_runner.initiate(self.job_rec, {"initiate": False})
        
        self.assertEqual(self.job_rec["job_url"], config_data.getByPath('mir_web', 'uri') + self.job_rec["job_identity"])
        self.assertEqual(str(self.job_rec["ident"]), str(identity.identity_from_string(self.t_job.href)))

        self.assertTrue(self.job_rec.has_key, "logEntries")
        self.assertEqual(len(self.job_rec["logEntries"]), 0)
        self.assertEqual(self.job_rec["logEntries"], [])

        self.assertTrue(self.job_rec.has_key, "issues")
        self.assertEqual(len(self.job_rec["issues"]), 0)
        self.assertEqual(self.job_rec["issues"], [])

        self.assertTrue(self.job_rec.has_key, "results_hash")
        self.assertEqual(len(self.job_rec["results_hash"]), 0)
        self.assertEqual(self.job_rec["results_hash"], [])

        self.assertTrue(self.job_rec.has_key, "inputs")
        self.assertEqual(len(self.job_rec["inputs"]), 0)
        self.assertEqual(self.job_rec["inputs"], [])

        self.assertTrue(self.job_rec.has_key, "documents")
        self.assertEqual(len(self.job_rec["documents"].keys()), 0)
        self.assertEqual(self.job_rec["documents"], {})

        self.assertEqual(len(self.job_rec['job_obj'].results), 1)
        stringpad = " Results Container @"
        size = len(self.job_rec['job_obj'].name) + len(stringpad)
        self.assertEqual(self.job_rec['job_obj'].results[0].name[:size], "%s%s" % (self.job_rec['job_obj'].name, stringpad))

        self.assertEqual(self.job_rec['script'], self.job_script)
        
        self.assertEqual(self.job_rec['input'], self.job_input_uri_list)
        
        xx = self.job_rec['script_dom'].toxml('utf-8').replace(r'&quot;', '"').replace(r'<?xml version="1.0" encoding="utf-8"?>', '')
        yy = self.job_rec['script_dom'].toxml('utf-8').replace(r'&quot;', '"')
        self.assertEqual(yy, self.job_script)

    testInitiate = defer.inlineCallbacks(testInitiate)    
        
