# third-party
import twisted.trial.unittest as unittest
import twisted.internet.defer as defer
import xml.dom.minidom as minidom
import re as re
import yaml as yaml

# product
import mir.script_runner.execution_node as en
import mir.config as config
import mandiant.windtalker.message_bus_injector as mbus_factory
import mir.identity as identity
import mir.script_runner.test.db as testdb
import mir.models as models
import mir.util.dtutil as mir_datetime
import mandiant.windtalker.util as util


# load the config for this service
config_data = config.MirConfig("mir")
# add configs for services we use
config_data.loadServiceConfig('agentcontroller')
config_data.loadServiceConfig('fileserver')
config_data.loadServiceConfig('search')
config_data.loadServiceConfig('scriptrunner')
config_data.loadServiceConfig('analyzer_dispatcher')


database = "/usr/lib/python2.5/site-packages/mir/script_runner/test/"

class ExecutionNodeTests(unittest.TestCase):
    timeout = 5                # Set a default timeout
   
    def __init__(self, test_to_run):
        unittest.TestCase.__init__(self, test_to_run)
        self.mbus = mbus_factory.MessageBusTestInjectorFactory("script_runner")
        self.local_queue = config_data.getByPath('analyzer_dispatcher', 'queues', 'postqueue')
        self.database = "/usr/lib/python2.5/site-packages/mir/script_runner/test/"
        
    def tearDown(self):
        pass

    def setUp(self, scriptfile="implicit_chaining_1.xml"):
        self.job_script = file(self.database + "data/job_scripts/%s" % scriptfile).read()
        
        self.job_schedule = "now"
        
        self.job_input_uri_list = "<input><uri>/workspaces/1/hosts/resources/1/</uri>\n<uri>/workspaces/1/hosts/resources/2/</uri></input>"
        
        self.job_xml = '%s%s\n<when>%s</when>\n%s\n</JobDefinition>' % (
                     '<?xml version="1.0"?>\n<JobDefinition xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" href="/workspaces/1/jobs/234/">',
                     re.sub(r'^<\?[^\?]+\?>', '', self.job_script),
                     re.sub(r'^<\?[^\?]+\?>', '', self.job_schedule),
                     re.sub(r'^<\?[^\?]+\?>', '', self.job_input_uri_list),
                  )

        self.db = testdb.ACTestObjectDB()
        self.t_job = models.Job("ScriptRunner TestJob #1", schedule=self.job_schedule, input=self.job_input_uri_list, script=self.job_script, workspace_id=1, id=14)
        self.t_res = models.ResultSet(name="%s Results Container @ %s" % (self.t_job.name, mir_datetime.strISO_now()), job=self.t_job, workspace_id=self.t_job.workspace_id)
        self.t_job.resultsets = [self.t_res]


    def XXtestCommandMessage(self):
        xx = en.ExecutionNode(config_data=config_data, mbus=self.mbus, resultset=self.t_res, command='Command 1', name='C0', params='Params', script='Script')
        
        cmd_msg = xx.command_mesg

        self.assertEqual(type(xx.command_mesg), dict)

        self.assertEqual(cmd_msg['results_queue'], util.makeQueueIdentity(xx.scriptrunner_ident, xx.resultSetQueue))
        del(cmd_msg['results_queue'])

        self.assertEqual(cmd_msg['script'], xx.script)
        del(cmd_msg['script'])

        self.assertEqual(cmd_msg['params'], xx.params)
        del(cmd_msg['params'])

        self.assertEqual(cmd_msg['command'], xx.command)
        del(cmd_msg['command'])

        self.assertEqual(cmd_msg['status_interval'], xx.status_interval)
        del(cmd_msg['status_interval'])

        self.assertEqual(cmd_msg['status_queue'], util.makeQueueIdentity(xx.scriptrunner_ident, xx.statusQueue))
        del(cmd_msg['status_queue'])

        self.assertEqual(cmd_msg['resultset'], xx.resultset_href)
        del(cmd_msg['resultset'])
        
        del(cmd_msg['user'])
        
        self.assertEqual(len(cmd_msg), 0)
        

    def XXtestInit(self):
        self.timeout = 10
        
        xx = en.ExecutionNode(config_data=config_data)
        
        self.assertEqual(xx.command, '')
        self.assertEqual(xx.params, '')
        self.assertEqual(xx.script, '')
        self.assertEqual(xx.chaining, None)
        self.assertEqual(xx.id != None, True)
        self.assertEqual(xx.name, None)
        self.assertEqual(xx.handler, None)
        self.assertEqual(xx.mbus, None)
        self.assertEqual(xx.db, None)
        self.assertIdentical(xx.config_data, config_data)
        self.assertEqual(xx.resultItemQueue, None)
        self.assertEqual(xx.resultSetQueue, None)
        self.assertEqual(xx.statusQueue, None)
        self.assertEqual(xx.workspace_id, 1)
        self.assertEqual(xx.status_interval, 5)
        self.assertEqual(xx.resolveInputSets, False)
        self.assertEqual(xx.resultset, None)
        self.assertEqual(xx.testing, False)
        self.assertEqual(xx.debug_level, 0)
        self.assertEqual(xx.commandStatusTimestamp, False)
        self.assertEqual(xx.commandStatus, False)
        self.assertEqual(xx.allOutputsSent, False)
        self.assertEqual(xx.allResultsReceived, False)
        self.assertEqual(xx.allInputsReceived, False)
        self.assertEqual(type(xx.allnodes), dict)
        self.assertEqual(len(xx.allnodes), 1)
        self.assertEqual(type(xx.inputMap), dict)
        self.assertEqual(len(xx.inputMap), 0)
        self.assertEqual(type(xx.children), list)
        self.assertEqual(len(xx.children), 0)
        self.assertEqual(type(xx.parents), list)
        self.assertEqual(len(xx.parents), 0)
        self.assertEqual(type(xx.subcommands), list)
        self.assertEqual(len(xx.subcommands), 0)
        self.assertEqual(type(xx.supercommands), list)
        self.assertEqual(len(xx.supercommands), 0)
        self.assertEqual(type(xx.inputItemListeners), dict)
        self.assertEqual(len(xx.inputItemListeners), 0)
        self.assertEqual(type(xx.outputItemListeners), dict)
        self.assertEqual(len(xx.outputItemListeners), 0)
        self.assertEqual(type(xx.inputSetListeners), dict)
        self.assertEqual(len(xx.inputSetListeners), 0)
        self.assertEqual(type(xx.outputSetListeners), dict)
        self.assertEqual(len(xx.outputSetListeners), 0)
        self.assertEqual(type(xx.delayedRegistrations), list)
        self.assertEqual(len(xx.delayedRegistrations), 0)
        self.assertEqual(type(xx.inputSet), list)
        self.assertEqual(len(xx.inputSet), 0)
        self.assertEqual(type(xx.configs), dict)
        self.assertEqual(len(xx.configs), 0)
        
        
        xx = en.ExecutionNode(config_data=config_data, workspace_id=3, mbus=self.mbus, command='XX', name='XXX', params='XXXX', script='XXXXX', chaining='none')
        
        self.assertEqual(xx.command, 'XX')
        self.assertEqual(xx.params, 'XXXX')
        self.assertEqual(xx.script, 'XXXXX')
        self.assertEqual(xx.chaining, 'none')
        self.assertEqual(xx.id != None, True)
        self.assertEqual(xx.name, 'XXX')
        self.assertEqual(xx.handler, None)
        self.assertIdentical(xx.mbus, self.mbus)
        self.assertEqual(xx.db, None)
        self.assertIdentical(xx.config_data, config_data)
        self.assertEqual(xx.resultItemQueue, "%s%s/item" % (config_data.getByPath('script_runner', 'queues', 'jobqueuebase'), xx.id))
        self.assertEqual(xx.resultSetQueue, "%s%s/set" % (config_data.getByPath('script_runner', 'queues', 'jobqueuebase'), xx.id))
        self.assertEqual(xx.statusQueue, "%s%s/status" % (config_data.getByPath('script_runner', 'queues', 'jobqueuebase'), xx.id))
        self.assertEqual(xx.workspace_id, 3)
        self.assertEqual(xx.status_interval, 5)
        self.assertEqual(xx.resolveInputSets, False)
        self.assertEqual(xx.resultset, None)
        self.assertEqual(xx.testing, False)
        self.assertEqual(xx.debug_level, 0)
        self.assertEqual(xx.commandStatusTimestamp, False)
        self.assertEqual(xx.commandStatus, False)
        self.assertEqual(xx.allOutputsSent, False)
        self.assertEqual(xx.allResultsReceived, False)
        self.assertEqual(xx.allInputsReceived, False)
        self.assertEqual(type(xx.allnodes), dict)
        self.assertEqual(len(xx.allnodes), 1)
        self.assertEqual(type(xx.inputMap), dict)
        self.assertEqual(len(xx.inputMap), 0)
        self.assertEqual(type(xx.children), list)
        self.assertEqual(len(xx.children), 0)
        self.assertEqual(type(xx.parents), list)
        self.assertEqual(len(xx.parents), 0)
        self.assertEqual(type(xx.subcommands), list)
        self.assertEqual(len(xx.subcommands), 0)
        self.assertEqual(type(xx.supercommands), list)
        self.assertEqual(len(xx.supercommands), 0)
        self.assertEqual(type(xx.inputItemListeners), dict)
        self.assertEqual(len(xx.inputItemListeners), 0)
        self.assertEqual(type(xx.outputItemListeners), dict)
        self.assertEqual(len(xx.outputItemListeners), 0)
        self.assertEqual(type(xx.inputSetListeners), dict)
        self.assertEqual(len(xx.inputSetListeners), 0)
        self.assertEqual(type(xx.outputSetListeners), dict)
        self.assertEqual(len(xx.outputSetListeners), 0)
        self.assertEqual(type(xx.delayedRegistrations), list)
        self.assertEqual(len(xx.delayedRegistrations), 0)
        self.assertEqual(type(xx.inputSet), list)
        self.assertEqual(len(xx.inputSet), 0)
        self.assertEqual(type(xx.configs), dict)
        self.assertEqual(len(xx.configs), 0)
                    

        self.assertIn(xx.resultItemQueue, self.mbus.queues)
        self.assertIn(xx.resultSetQueue, self.mbus.queues)
        self.assertIn(xx.statusQueue, self.mbus.queues)
        
        xx = en.ExecutionNode(config_data=config_data, testing=True, resultset=self.t_res, handler='AgentController', db=self.db, resolveInputSets=True, debug_level=4)
        
        self.assertEqual(xx.handler, 'AgentController')
        self.assertIdentical(xx.db, self.db)
        self.assertEqual(xx.resolveInputSets, True)
        self.assertIdentical(xx.resultset, self.t_res)
        self.assertEqual(xx.testing, True)
        self.assertEqual(xx.debug_level, 4)
         
        

    def XXtestRandomOutputListener(self):
        job_rec_val = 14
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', mbus=self.mbus)
        t_outputSet = ['abcd', 'abcde']
        
        def xxx(outputSet, sourceNode, job_rec):
            self.receivedOutputSet = True
            
            self.assertEqual(job_rec, job_rec_val)
            self.assertEqual(sourceNode, xx)
            
            for x in t_outputSet:
                self.assertIn(x, outputSet)
            
        xx.outputSetListeners['abc'] = lambda x, y: xxx(x, y, job_rec_val)
        
        xx.receiveOutputSet(t_outputSet)

        self.assertEqual(self.receivedOutputSet, True)
        
        
    def XXtestHostResolution_1(self):
        import mir.script_runner.test.db as testdb
        db = testdb.ACTestObjectDB()
        
        xx = en.ExecutionNode(config_data=config_data, resolveInputSets=True, command='AuditHostScriptCommand', name='XX', mbus=self.mbus, db=db)

        inputItems = map(lambda x: str(identity.Identity(1, object_id=x+2, type='Host')), range(4))
        xx.receiveInputSet(inputItems)
        
        
    def XXtestTraceOutput_0(self):
        ww = en.ExecutionNode(config_data=config_data, command='Script', name='S0', chaining="implicit")
        outputMap = {
            '/workspaces/1/documents/all/21/': '/workspaces/1/hosts/all/01',
            '/workspaces/1/documents/all/20/': '/workspaces/1/hosts/all/07',
            '/workspaces/1/documents/all/22/': '/workspaces/1/hosts/all/07',
            '/workspaces/1/documents/all/24/': '/workspaces/1/hosts/all/27',
            '/workspaces/1/documents/all/26/': '/workspaces/1/hosts/all/27',
            '/workspaces/1/documents/all/27/': '/workspaces/1/hosts/all/47',
            '/workspaces/1/documents/all/23/': '/workspaces/1/hosts/all/47',
            '/workspaces/1/documents/all/25/': '/workspaces/1/hosts/all/47',
        }
        ww.outputMap = dict([(k, v) for k, v in outputMap.iteritems()])
        ww.allInputsReceived = True
        ww.allOutputsSent = True

        outputTrace = ww.traceOutput()
        
        for k, v in outputMap.iteritems():
            self.assertEqual(v, outputTrace[k])
            

    def XXtestTraceOutput_1(self):
        inputItems = ['/abc/1/', '/abc/2/', '/abc/3/', '/abc/4/']
        
        nodelist = {}
        ww = en.ExecutionNode(config_data=config_data, command='Script', name='S0', nodelist=nodelist, chaining="implicit")
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)

        xx.setSuperCommand(ww)
        yy.setSuperCommand(ww)
        yy.setParent(xx)
        
        for zz in (yy, xx, ww):
            self.assertEqual(len(zz.inputSet), 0)
            self.assertEqual(len(zz.inputMap.keys()), 0)
            self.assertEqual(zz.allInputsReceived, False)
            self.assertEqual(zz.allResultsReceived, False)
        
        xx.requestInputSet(ww, xx.receiveInputSet)
        yy.requestOutputSet(xx, yy.receiveInputSet)
        ww.requestOutputSet(yy, ww.receiveOutputSet)

        ww.inputSet = inputItems[:]
        ww.inputMap = dict([(x, None) for x in ww.inputSet])
        
        xx.inputSet = inputItems[:]
        xx.inputMap = {'/abc/1/': '/workspaces/1/hosts/all/1/', 
                       '/abc/2/': '/workspaces/1/hosts/all/14/',
                       '/abc/3/': '/workspaces/1/hosts/all/22/',
                       '/abc/4/': '/workspaces/1/hosts/all/167/',}
        xx.outputSet = xx.inputMap.values()
        xx.outputMap = dict([(y, x) for x, y in xx.inputMap.iteritems()])
        xx.allInputsReceived = True
        xx.allOutputsSent = True

        yy.inputSet = xx.outputSet
        yy.inputMap = {'/workspaces/1/hosts/all/1/': '/workspaces/1/documents/all/422/', 
                       '/workspaces/1/hosts/all/14/': '/workspaces/1/documents/all/467/',
                       '/workspaces/1/hosts/all/22/': '/workspaces/1/documents/all/1422/',
                       '/workspaces/1/hosts/all/167/': '/workspaces/1/documents/all/2/',}
        yy.outputSet = yy.inputMap.values()
        yy.outputMap = dict([(y, x) for x, y in yy.inputMap.iteritems()])
        yy.allInputsReceived = True
        yy.allOutputsSent = True
        
        ww.outputSet = yy.outputSet[:]
        ww.allInputsReceived = True
        ww.allOutputsSent = True
        

        for zz in (yy, xx, ww):
            self.assertEqual(zz.allInputsReceived, True)
            self.assertEqual(zz.allOutputsSent, True)
        
        for zz in (yy, xx, ww):
            self.assertEqual(len(zz.inputSet), len(inputItems))
            
            self.assertEqual(zz.allInputsReceived, True)
            self.assertEqual(zz.allOutputsSent, True)

        outputMap = ww.traceOutput()
        
        for input in inputItems:
            self.assertEqual(input, outputMap[yy.inputMap[xx.inputMap[input]]])
            

        
        
    def XXtestTraceOutput_2(self):
        inputItems = ['/abc/1/', '/abc/2/', '/abc/3/', '/abc/4/']
        
        def msgBack(message):
            self.result = yaml.safe_load(message._message)
            
            resmessage = []
            for i in self.result['inputs']:
                resmessage.append({'input_uri': i, 'output_uri': "%s%s" % (i, i)})
                
            resmessage = {'results':resmessage}
            self.mbus.sendMessagetoQueue(self.result['results_queue'], yaml.safe_dump(resmessage))
           
        
        self.mbus.add_queue(self.local_queue, msgBack)
        
        nodelist = {}
        ww = en.ExecutionNode(config_data=config_data, command='Script', name='S0', mbus=self.mbus, nodelist=nodelist, chaining="implicit")
        xx = en.ExecutionNode(config_data=config_data, handler='AnalyzerController', command='A', name='XX', mbus=self.mbus, nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, handler='AnalyzerController', command='B', name='YY', mbus=self.mbus, nodelist=nodelist)

        xx.setSuperCommand(ww)
        yy.setSuperCommand(ww)
        yy.setParent(xx)
        
        for zz in (yy, xx, ww):
            self.assertEqual(len(zz.inputSet), 0)
            self.assertEqual(len(zz.inputMap.keys()), 0)
            self.assertEqual(zz.allInputsReceived, False)
            self.assertEqual(zz.allResultsReceived, False)
        
        xx.requestInputSet(ww, xx.receiveInputSet)
        yy.requestOutputSet(xx, yy.receiveInputSet)
        ww.requestOutputSet(yy, ww.receiveOutputSet)

        ww.receiveInputSet(inputItems)

        for zz in (yy, xx, ww):
            self.assertEqual(zz.allInputsReceived, True)
            self.assertEqual(zz.allOutputsSent, True)
        
        for zz in (yy, xx, ww):
            self.assertEqual(len(zz.inputSet), len(inputItems))
            
            self.assertEqual(zz.allInputsReceived, True)
            self.assertEqual(zz.allOutputsSent, True)

        outputMap = ww.traceOutput()
        
        for input in inputItems:
            self.assertEqual(input, outputMap[yy.inputMap[xx.inputMap[input]]])
            

        
    def XXtestChaining_2(self):
        inputItems = ['/abc/1/', '/abc/2/', '/abc/3/', '/abc/4/']
        
        def msgBack(message):
            self.result = yaml.safe_load(message._message)
            
            for i in self.result['inputs']:
                resmessage = {'input_uri': i, 'output_uri': "%s%s" % (i, i)}
                
                resmessage = {'results':resmessage}
                self.mbus.sendMessagetoQueue(self.result['results_queue'], yaml.safe_dump(resmessage))
           
        
        self.mbus.add_queue(self.local_queue, msgBack)
        
        nodelist = {}
        xx = en.ExecutionNode(config_data=config_data, handler='AnalyzerController', command='A', name='XX', mbus=self.mbus, nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, handler='AnalyzerController', command='B', name='YY', mbus=self.mbus, nodelist=nodelist)

        for zz in (yy, xx):
            self.assertEqual(len(zz.inputSet), 0)
            self.assertEqual(len(zz.inputMap.keys()), 0)
            self.assertEqual(zz.allInputsReceived, False)
            self.assertEqual(zz.allResultsReceived, False)
        
        yy.requestOutputSet(xx, yy.receiveInputItem)
        xx.receiveInputSet(inputItems)
        
        for zz in (yy, xx):
            self.assertEqual(len(zz.inputSet), len(inputItems))
            
            self.assertEqual(zz.allInputsReceived, True)
            self.assertEqual(zz.allResultsReceived, True)
            
            self.assertEqual(len(zz.outputSet), len(zz.inputSet))
            self.assertEqual(len(zz.outputMap.keys()), len(zz.inputSet))
    
            for i in range(len(inputItems)):
                self.assertEqual(zz.outputSet[i], "%s%s" % (zz.inputSet[i], zz.inputSet[i]))
                self.assertEqual(zz.inputMap[zz.inputSet[i]], "%s%s" % (zz.inputSet[i], zz.inputSet[i]))
                self.assertEqual(zz.outputMap[zz.inputMap[zz.inputSet[i]]], zz.inputSet[i])


        
    def XXtestChaining(self):
        inputItems = ['abc1', 'abc2', 'abc3', 'abc4']
        
        def msgBack(message):
            self.result = yaml.safe_load(message._message)
            
            resmessage = []
            for i in self.result['inputs']:
                resmessage.append({'input_uri': i, 'output_uri': "%s%s" % (i, i)})
            
            resmessage = {'results':resmessage}    
            self.mbus.sendMessagetoQueue(self.result['results_queue'], yaml.safe_dump(resmessage))
           
        
        self.mbus.add_queue(self.local_queue, msgBack)
        
        xx = en.ExecutionNode(config_data=config_data, handler='AnalyzerController', command='A', name='XX', mbus=self.mbus)
        yy = en.ExecutionNode(config_data=config_data, handler='AnalyzerController', command='B', name='YY', mbus=self.mbus)

        for zz in (yy, xx):
            self.assertEqual(len(zz.inputSet), 0)
            self.assertEqual(len(zz.inputMap.keys()), 0)
            self.assertEqual(zz.allInputsReceived, False)
            self.assertEqual(zz.allResultsReceived, False)
        
        yy.requestOutputSet(xx, yy.receiveInputSet)
        xx.receiveInputSet(inputItems)
        
        for zz in (yy, xx):
            self.assertEqual(len(zz.inputSet), len(inputItems))
            
            self.assertEqual(zz.allInputsReceived, True)
            self.assertEqual(zz.allResultsReceived, True)
            
            self.assertEqual(len(zz.outputSet), len(zz.inputSet))
            self.assertEqual(len(zz.outputMap.keys()), len(zz.inputSet))
    
            for i in range(len(inputItems)):
                self.assertEqual(zz.outputSet[i], "%s%s" % (zz.inputSet[i], zz.inputSet[i]))
                self.assertEqual(zz.inputMap[zz.inputSet[i]], "%s%s" % (zz.inputSet[i], zz.inputSet[i]))
                self.assertEqual(zz.outputMap[zz.inputMap[zz.inputSet[i]]], zz.inputSet[i])


        
    def XXtestAllResultsReceived_2(self):
        inputItems = ['abc1', 'abc2', 'abc3', 'abc4']
        
        def msgBack(message):
            self.result = yaml.safe_load(message._message)
            
            for i in self.result['inputs']:
                resmessage = {'input_uri': i, 'output_uri': "%s%s" % (i, i)}
                
                resmessage = {'results':resmessage}
                self.mbus.sendMessagetoQueue(self.result['results_queue'], yaml.safe_dump(resmessage))
            
        
        self.mbus.add_queue(self.local_queue, msgBack)
        
        xx = en.ExecutionNode(config_data=config_data, handler='AnalyzerController', command='A', name='XX', mbus=self.mbus)

        self.assertEqual(len(xx.inputSet), 0)
        self.assertEqual(len(xx.inputMap.keys()), 0)
        self.assertEqual(xx.allInputsReceived, False)
        self.assertEqual(xx.allResultsReceived, False)
        
        xx.receiveInputSet(inputItems)
        
        self.assertEqual(len(xx.inputSet), len(inputItems))
        self.assertEqual(len(xx.inputMap.keys()), len(inputItems))
        
        for i in inputItems:
            self.assertIn(i, xx.inputMap.keys())
            self.assertIn(i, xx.inputSet)
            
        self.assertEqual(xx.allInputsReceived, True)
        self.assertEqual(xx.allResultsReceived, True)
        
        self.assertEqual(len(xx.outputSet), len(xx.inputSet))
        self.assertEqual(len(xx.outputMap.keys()), len(xx.inputSet))

        for i in range(len(inputItems)):
            self.assertEqual(xx.inputSet[i], inputItems[i])
            self.assertEqual(xx.outputSet[i], "%s%s" % (inputItems[i], inputItems[i]))
            self.assertEqual(xx.inputMap[inputItems[i]], "%s%s" % (inputItems[i], inputItems[i]))
            self.assertEqual(xx.outputMap[xx.inputMap[inputItems[i]]], inputItems[i])


        
    def XXtestAllResultsReceived(self):
        inputItems = ['abc1', 'abc2', 'abc3', 'abc4']
        
        def msgBack(message):
            self.result = yaml.safe_load(message._message)
            
            resmessage = []
            for i in self.result['inputs']:
                resmessage.append({'input_uri': i, 'output_uri': "%s%s" % (i, i)})
            
            resmessage = {'results':resmessage}
            self.mbus.sendMessagetoQueue(self.result['results_queue'], yaml.safe_dump(resmessage))
            
        
        self.mbus.add_queue(self.local_queue, msgBack)
        
        xx = en.ExecutionNode(config_data=config_data, handler='AnalyzerController', command='A', name='XX', mbus=self.mbus)
        
        self.assertEqual(len(xx.inputSet), 0)
        self.assertEqual(len(xx.inputMap.keys()), 0)
        self.assertEqual(xx.allInputsReceived, False)
        self.assertEqual(xx.allResultsReceived, False)
        
        xx.receiveInputSet(inputItems)
        
        self.assertEqual(len(xx.inputSet), len(inputItems))
        self.assertEqual(len(xx.inputMap.keys()), len(inputItems))
        
        for i in inputItems:
            self.assertIn(i, xx.inputMap.keys())
            self.assertIn(i, xx.inputSet)
            
        self.assertEqual(xx.allInputsReceived, True)
        self.assertEqual(xx.allResultsReceived, True)
        
        self.assertEqual(len(xx.outputSet), len(xx.inputSet))
        self.assertEqual(len(xx.outputMap.keys()), len(xx.inputSet))

        for i in range(len(inputItems)):
            self.assertEqual(xx.inputSet[i], inputItems[i])
            self.assertEqual(xx.outputSet[i], "%s%s" % (inputItems[i], inputItems[i]))
            self.assertEqual(xx.inputMap[inputItems[i]], "%s%s" % (inputItems[i], inputItems[i]))
            self.assertEqual(xx.outputMap[xx.inputMap[inputItems[i]]], inputItems[i])

        
    def XXtestAllInputsReceived(self):
        inputItem = 'abc1'
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', mbus=self.mbus)
        self.assertEqual(len(xx.inputSet), 0)
        self.assertEqual(len(xx.inputMap.keys()), 0)
        self.assertEqual(xx.allInputsReceived, False)
        
        xx.receiveInputItem(inputItem, sourceNode=xx)
        
        self.assertEqual(len(xx.inputSet), 1)
        self.assertEqual(len(xx.inputMap.keys()), 1)
        self.assertIn(xx.inputSet[0], xx.inputMap.keys())
        self.assertEqual(xx.inputSet[0], inputItem)
        self.assertIdentical(xx.inputMap[inputItem], None)
        self.assertEqual(xx.allInputsReceived, False)
        
        inputItem2 = 'abc2'
        xx.receiveInputItem(inputItem2, sourceNode=xx)
        
        self.assertEqual(len(xx.inputSet), 2)
        self.assertEqual(len(xx.inputMap.keys()), 2)
        self.assertIn(xx.inputSet[1], xx.inputMap.keys())
        self.assertEqual(xx.inputSet[1], inputItem2)
        self.assertIdentical(xx.inputMap[inputItem2], None)
        self.assertEqual(xx.allInputsReceived, False)
        
        inputItem3 = 'abc3'
        xx.receiveInputItem(inputItem3, sourceNode=xx)
        
        self.assertEqual(len(xx.inputSet), 3)
        self.assertEqual(len(xx.inputMap.keys()), 3)
        self.assertIn(xx.inputSet[2], xx.inputMap.keys())
        self.assertEqual(xx.inputSet[2], inputItem3)
        self.assertIdentical(xx.inputMap[inputItem3], None)
        self.assertEqual(xx.allInputsReceived, False)
        
        inputSet = ['abc4']
        xx.receiveInputSet(inputSet)
        
        self.assertEqual(len(xx.inputSet), 4)
        self.assertEqual(len(xx.inputMap.keys()), 4)
        self.assertIn(xx.inputSet[3], xx.inputMap.keys())
        self.assertEqual(xx.inputSet[3], inputSet[0])
        self.assertIdentical(xx.inputMap[inputSet[0]], None)
        self.assertEqual(xx.allInputsReceived, True)
        
    def XXtestReceiveInputItem(self):
        
        def msgBack(message):
            self.result = yaml.safe_load(message._message)
            
            for i in self.result['inputs']:
                resmessage = {'input_uri': i, 'output_uri': "%s%s" % (i, i)}
               
            resmessage = {'results':resmessage}
            self.mbus.sendMessagetoQueue(self.result['results_queue'], yaml.safe_dump(resmessage))
            
        
        self.mbus.add_queue(self.local_queue, msgBack)
        
        inputItem = 'abc1'
        
        xx = en.ExecutionNode(config_data=config_data, handler='AnalyzerController', command='A', name='XX', mbus=self.mbus)
        xx.receiveInputItem(inputItem, sourceNode=xx)
        
        for i in (inputItem, ):
            self.assertEqual(xx.inputMap[i], "%s%s" % (i, i))
        
        inputItem2 = 'abc2'
        
        xx.receiveInputItem(inputItem2, sourceNode=xx)
        
        for i in (inputItem, inputItem2):
            self.assertEqual(xx.inputMap[i], "%s%s" % (i, i))
        
        inputItem3 = 'abc3'
        
        xx.receiveInputItem(inputItem3, sourceNode=xx)
        
        for i in (inputItem, inputItem2, inputItem3):
            self.assertEqual(xx.inputMap[i], "%s%s" % (i, i))
        

    def XXtestReceiveInputSet(self):
        
        def msgBack(message):
            self.result = yaml.safe_load(message._message)
            
            resmessage = []
            for i in self.result['inputs']:
                resmessage.append({'input_uri': i, 'output_uri': "%s%s" % (i, i)})
            
            resmessage = {'results':resmessage}    
            self.mbus.sendMessagetoQueue(self.result['results_queue'], yaml.safe_dump(resmessage))
            
        
        self.mbus.add_queue(self.local_queue, msgBack)
        
        inputItems = [ 'abc1', 'abc2' ]
        
        xx = en.ExecutionNode(config_data=config_data, handler='AnalyzerController', command='A', name='XX', mbus=self.mbus)
        xx.receiveInputSet(inputItems)
        
        for i in inputItems:
            self.assertEqual(xx.inputMap[i], "%s%s" % (i, i))
        

    def XXtestReceiveResultItem(self):
        
        def msgBack(message):
            pass
        
        self.mbus.add_queue(self.local_queue, msgBack)
        
        inputItem = 'abc'
        outputItem = 'def'
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', mbus=self.mbus)
        xx.receiveInputItem(inputItem, sourceNode=xx)
        
        msg = {'results':{'input_uri':inputItem, 'output_uri':outputItem}}
        self.mbus.sendMessagetoQueue(util.makeQueueIdentity(xx.scriptrunner_ident, xx.resultItemQueue), yaml.safe_dump(msg), replyto=self.local_queue)
        
        self.assertEqual(xx.inputMap[inputItem], outputItem)
        

    def XXtestReceiveResultSet(self):
        
        def msgBack(message):
            pass
        
        self.mbus.add_queue(self.local_queue, msgBack)
        
        inputItems = [ 'abc1', 'abc2', 'abc3', 'abc4', 'abc5', ]
        outputItems = [ 'def1', 'def2', 'def3', 'def4', 'def5', ]
        
        message = []
        for (i, j) in zip(inputItems, outputItems):
            message.append({'input_uri': i, 'output_uri': j})
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', mbus=self.mbus)
        xx.receiveInputSet(inputItems)
        
        message = {'results':message}
        self.mbus.sendMessagetoQueue(util.makeQueueIdentity(xx.scriptrunner_ident, xx.resultSetQueue), yaml.safe_dump(message), replyto=self.local_queue)
        
        for (i, j) in zip(inputItems, outputItems):
            self.assertEqual(xx.inputMap[i], j)
        

    def XXtestReceiveInputItem_2(self):
        inputItem = ["abc"]
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX')

        self.assertEqual(0, len(xx.inputMap))
        
        xx.receiveInputItem(inputItem, sourceNode=xx)
        
        self.assertEqual(1, len(xx.inputMap))
        self.assertEqual(None, xx.inputMap[inputItem[0]])
        
        inputItem2 = ["abc1", "abc2"]
        
        xx.receiveInputItem(inputItem2, sourceNode=xx)
        
        self.assertEqual(3, len(xx.inputMap))
        for i in inputItem2:
            self.assertEqual(None, xx.inputMap[i])
        self.assertEqual(None, xx.inputMap[inputItem[0]])


    def XXtestReceiveInputItem(self):
        inputItem = "abc"
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX')

        self.assertEqual(0, len(xx.inputMap))
        
        xx.receiveInputItem(inputItem, sourceNode=xx)
        
        self.assertEqual(1, len(xx.inputMap))
        self.assertEqual(None, xx.inputMap[inputItem])
        
        inputItem2 = "abc1"
        
        xx.receiveInputItem(inputItem2, sourceNode=xx)
        
        self.assertEqual(2, len(xx.inputMap))
        self.assertEqual(None, xx.inputMap[inputItem2])
        self.assertEqual(None, xx.inputMap[inputItem])
        
        inputItem3 = "abc2"
        
        xx.receiveInputItem(inputItem3, sourceNode=xx)
        
        self.assertEqual(3, len(xx.inputMap))
        self.assertEqual(None, xx.inputMap[inputItem3])
        self.assertEqual(None, xx.inputMap[inputItem2])
        self.assertEqual(None, xx.inputMap[inputItem])


    def XXtestReceiveInputSet(self):
        inputSet = [
            'abc', 'abc2', 'abc3', 'abc4',
        ]
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist={})

        self.assertEqual(0, len(xx.inputMap))
        
        xx.receiveInputSet(inputSet)
        
        self.assertEqual(len(inputSet), len(xx.inputMap))
        for i in inputSet:
            self.assertEqual(None, xx.inputMap[i])
            
        inputSet2 = [
            'xabc', 'xabc2', 'xabc3', 'xabc4',
        ]
        
        xx.receiveInputSet(inputSet2)
        
        self.assertEqual(len(inputSet) + len(inputSet2), len(xx.inputMap))
        for i in inputSet:
            self.assertEqual(None, xx.inputMap[i])
        for i in inputSet2:
            self.assertEqual(None, xx.inputMap[i])
            

    def XXtestParsingJobInput_3(self):
        """Parsing script doc into executionNode tree."""
        self.timeout = 5                # Set a reasonable timeout

        ######
        xxinput = file(database + "data/inputs/host_uris.xml").read()

        inputDom = minidom.parseString("<input>%s</input>" % xxinput)
        inputSet = {}
        
        for uri in inputDom.getElementsByTagName('uri'):
            inputSet[uri.childNodes[0].nodeValue] = uri.toxml()
            
        inputs = en.parseJobInput(xxinput)
        
        self.assertEqual(len(inputs), len(inputSet.keys()))
                 
        for xx in inputSet.keys():
            self.assertIn(xx, inputs)

    
    def XXtestParsingJobInput_4(self):
        """Parsing script doc into executionNode tree."""
        self.timeout = 5                # Set a reasonable timeout

        ######
        xxinput = file(database + "data/inputs/wrapped_host_uris.xml").read()

        inputDom = minidom.parseString(xxinput)
        inputSet = {}
        
        for uri in inputDom.getElementsByTagName('uri'):
            inputSet[uri.childNodes[0].nodeValue] = uri.toxml()
            
        inputs = en.parseJobInput(xxinput)
        
        self.assertEqual(len(inputs), len(inputSet.keys()))
                 
        for xx in inputSet.keys():
            self.assertIn(xx, inputs)

    
    def XXtestParseJobInput_1(self):
        input = "Trash"
        inputs = en.parseJobInput(input)
        
        self.assertEqual(0, len(inputs))
        
        input = "<urn>abc</urn>"
        inputs = en.parseJobInput(input)
        
        self.assertEqual(0, len(inputs))
        
        val = "abc"
        input = "<uri>%s</uri>" % val
        inputs = en.parseJobInput(input)
        
        self.assertEqual(1, len(inputs))
        self.assertEqual(inputs[0], val)
        
        val = "abc"
        val2 = "abcde"
        input = "<uri>%s</uri><uri>%s</uri>" % (val, val2)
        inputs = en.parseJobInput(input)
        
        self.assertEqual(2, len(inputs))
        self.assertIn(val, inputs)
        self.assertIn(val2, inputs)
        
        val = "abc"
        input = "<input><uri>%s</uri></input>" % val
        inputs = en.parseJobInput(input)
        
        self.assertEqual(1, len(inputs))
        self.assertEqual(inputs[0], val)
        
        val = "abc"
        val2 = "abcde"
        input = "<blah><booya><uri>%s</uri><uri>%s</uri></booya></blah>" % (val, val2)
        inputs = en.parseJobInput(input)
        
        self.assertEqual(2, len(inputs))
        self.assertIn(val, inputs)
        self.assertIn(val2, inputs)
        
    def XXtestParseJobInput_2(self):
        set_length = 30
        xxinputs = []
        input_template = "/workspaces/1/documents/%s/"
        
        for i in range(set_length):
            xxinputs.append("<uri>" + input_template % i + "</uri>")
            
        inputs = en.parseJobInput("\n".join(xxinputs))
        
        self.assertEqual(set_length, len(inputs))
        
        for i in range(set_length):
            self.assertIn(input_template % i, inputs)
       

    def XXtestReportStatus_2(self):
        inputSet = [
            'abc', 'abc2', 'abc3', 'abc4',
        ]

        nodelist = {}
        xx = en.ExecutionNode(config_data=config_data, command='Script', name='XX', chaining='implicit', nodelist=nodelist)
        aa = en.ExecutionNode(config_data=config_data, command='AA', name='AXX', nodelist=nodelist)
        bb = en.ExecutionNode(config_data=config_data, command='BB', name='BXX', nodelist=nodelist)
        cc = en.ExecutionNode(config_data=config_data, command='CC', name='CXX', nodelist=nodelist)

        aa.setSuperCommand(xx)
        bb.setSuperCommand(xx)
        cc.setSuperCommand(xx)

        aa.requestInputSet(xx, aa.receiveInputSet)
        bb.requestInputSet(aa, bb.receiveInputSet)
        cc.requestInputSet(bb, cc.receiveInputSet)
        xx.requestOutputSet(cc, xx.receiveOutputSet)
        
        self.assertEqual(aa.reportStatus(), 'Pending')
        self.assertEqual(bb.reportStatus(), 'Pending')
        self.assertEqual(cc.reportStatus(), 'Pending')
        self.assertEqual(xx.reportStatus(), 'Pending')
                
        ###############
        
        xx.inputMap = {'abc': None, 'abc2': None, 'abc3': None, 'abc4': None}
        xx.inputSet = xx.inputMap.keys()
        xx.allInputsReceived = True
        aa.inputMap = {'abc': None, 'abc2': None, 'abc3': None, 'abc4': None}
        aa.inputSet = aa.inputMap.keys()
        aa.allInputsReceived = True
        bb.inputMap = {'abc': None, 'abc2': None, 'abc3': None, 'abc4': None}
        bb.inputSet = bb.inputMap.keys()
        bb.allInputsReceived = True
        cc.inputMap = {'abc': None, 'abc2': None, 'abc3': None, 'abc4': None}
        cc.inputSet = cc.inputMap.keys()
        cc.allInputsReceived = True
        
        self.assertEqual(aa.reportStatus(), '0 of 4 Inputs Complete')
        self.assertEqual(bb.reportStatus(), '0 of 4 Inputs Complete')
        self.assertEqual(cc.reportStatus(), '0 of 4 Inputs Complete')
        self.assertEqual(xx.reportStatus(), '0% Complete')
                
    def XXtestReportStatus_3(self):
        inputSet = [
            'abc', 'abc2', 'abc3', 'abc4',
        ]

        nodelist = {}
        xx = en.ExecutionNode(config_data=config_data, command='Script', name='XX', chaining='implicit', nodelist=nodelist)
        aa = en.ExecutionNode(config_data=config_data, command='AA', name='AXX', nodelist=nodelist)
        bb = en.ExecutionNode(config_data=config_data, command='BB', name='BXX', nodelist=nodelist)
        cc = en.ExecutionNode(config_data=config_data, command='CC', name='CXX', nodelist=nodelist)

        aa.setSuperCommand(xx)
        bb.setSuperCommand(xx)
        cc.setSuperCommand(xx)

        aa.requestInputSet(xx, aa.receiveInputSet)
        bb.requestInputSet(aa, bb.receiveInputSet)
        cc.requestInputSet(bb, cc.receiveInputSet)
        xx.requestOutputSet(cc, xx.receiveOutputSet)
        
        self.assertEqual(aa.reportStatus(), 'Pending')
        self.assertEqual(bb.reportStatus(), 'Pending')
        self.assertEqual(cc.reportStatus(), 'Pending')
        self.assertEqual(xx.reportStatus(), 'Pending')
                
        ###############
        
        xx.inputMap = {'abc': None, 'abc2': None, 'abc3': None, 'abc4': None}
        xx.inputSet = xx.inputMap.keys()
        xx.allInputsReceived = True
        aa.inputMap = {'abc': 1, 'abc2': 1, 'abc3': None, 'abc4': None}
        aa.inputSet = aa.inputMap.keys()
        aa.allInputsReceived = True
        bb.inputMap = {'abc': None, 'abc2': None, 'abc3': None, 'abc4': None}
        bb.inputSet = bb.inputMap.keys()
        bb.allInputsReceived = True
        cc.inputMap = {'abc': None, 'abc2': None, 'abc3': None, 'abc4': None}
        cc.inputSet = cc.inputMap.keys()
        cc.allInputsReceived = True
        
        self.assertEqual(aa.reportStatus(), '2 of 4 Inputs Complete')
        self.assertEqual(bb.reportStatus(), '0 of 4 Inputs Complete')
        self.assertEqual(cc.reportStatus(), '0 of 4 Inputs Complete')
        self.assertEqual(xx.reportStatus(), '16% Complete')

    def XXtestReportStatus_4(self):
        inputSet = [
            'abc', 'abc2', 'abc3', 'abc4',
        ]

        nodelist = {}
        xx = en.ExecutionNode(config_data=config_data, command='Script', name='XX', chaining='implicit', nodelist=nodelist)
        aa = en.ExecutionNode(config_data=config_data, command='AA', name='AXX', nodelist=nodelist)
        bb = en.ExecutionNode(config_data=config_data, command='BB', name='BXX', nodelist=nodelist)
        cc = en.ExecutionNode(config_data=config_data, command='CC', name='CXX', nodelist=nodelist)

        aa.setSuperCommand(xx)
        bb.setSuperCommand(xx)
        cc.setSuperCommand(xx)

        aa.requestInputSet(xx, aa.receiveInputSet)
        bb.requestInputSet(aa, bb.receiveInputSet)
        cc.requestInputSet(bb, cc.receiveInputSet)
        xx.requestOutputSet(cc, xx.receiveOutputSet)
        
        self.assertEqual(aa.reportStatus(), 'Pending')
        self.assertEqual(bb.reportStatus(), 'Pending')
        self.assertEqual(cc.reportStatus(), 'Pending')
        self.assertEqual(xx.reportStatus(), 'Pending')
                
        ###############
        
        xx.inputMap = {'abc': 1, 'abc2': None, 'abc3': None, 'abc4': None}
        xx.inputSet = xx.inputMap.keys()
        xx.allInputsReceived = True
        aa.inputMap = {'abc': 1, 'abc2': 1, 'abc3': None, 'abc4': None}
        aa.inputSet = aa.inputMap.keys()
        aa.allInputsReceived = True
        bb.inputMap = {'abc': 1, 'abc2': None, 'abc3': None, 'abc4': None}
        bb.inputSet = bb.inputMap.keys()
        bb.allInputsReceived = True
        cc.inputMap = {'abc': 1, 'abc2': None, 'abc3': None, 'abc4': None}
        cc.inputSet = cc.inputMap.keys()
        cc.allInputsReceived = True
        
        self.assertEqual(aa.reportStatus(), '2 of 4 Inputs Complete')
        self.assertEqual(bb.reportStatus(), '1 of 4 Inputs Complete')
        self.assertEqual(cc.reportStatus(), '1 of 4 Inputs Complete')
        self.assertEqual(xx.reportStatus(), '33% Complete')

    def XXtestReportStatus_5(self):
        inputSet = [
            'abc', 'abc2', 'abc3', 'abc4',
        ]

        nodelist = {}
        xx = en.ExecutionNode(config_data=config_data, command='Script', name='XX', chaining='implicit', nodelist=nodelist)
        aa = en.ExecutionNode(config_data=config_data, command='AA', name='AXX', nodelist=nodelist)
        bb = en.ExecutionNode(config_data=config_data, command='BB', name='BXX', nodelist=nodelist)
        cc = en.ExecutionNode(config_data=config_data, command='CC', name='CXX', nodelist=nodelist)

        aa.setSuperCommand(xx)
        bb.setSuperCommand(xx)
        cc.setSuperCommand(xx)

        aa.requestInputSet(xx, aa.receiveInputSet)
        bb.requestInputSet(aa, bb.receiveInputSet)
        cc.requestInputSet(bb, cc.receiveInputSet)
        xx.requestOutputSet(cc, xx.receiveOutputSet)
        
        self.assertEqual(aa.reportStatus(), 'Pending')
        self.assertEqual(bb.reportStatus(), 'Pending')
        self.assertEqual(cc.reportStatus(), 'Pending')
        self.assertEqual(xx.reportStatus(), 'Pending')
                
        ###############
        
        xx.inputMap = {'abc': 1, 'abc2': None, 'abc3': None, 'abc4': None}
        xx.inputSet = xx.inputMap.keys()
        xx.allInputsReceived = True
        aa.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': None}
        aa.inputSet = aa.inputMap.keys()
        aa.allInputsReceived = True
        bb.inputMap = {'abc': 1, 'abc2': 1, 'abc3': None, 'abc4': None}
        bb.inputSet = bb.inputMap.keys()
        bb.allInputsReceived = True
        cc.inputMap = {'abc': 1, 'abc2': None, 'abc3': None, 'abc4': None}
        cc.inputSet = cc.inputMap.keys()
        cc.allInputsReceived = True
        
        self.assertEqual(aa.reportStatus(), '3 of 4 Inputs Complete')
        self.assertEqual(bb.reportStatus(), '2 of 4 Inputs Complete')
        self.assertEqual(cc.reportStatus(), '1 of 4 Inputs Complete')
        self.assertEqual(xx.reportStatus(), '50% Complete')

    def XXtestReportStatus_7(self):
        inputSet = [
            'abc', 'abc2', 'abc3', 'abc4',
        ]

        nodelist = {}
        xx = en.ExecutionNode(config_data=config_data, command='Script', name='XX', chaining='implicit', nodelist=nodelist)
        aa = en.ExecutionNode(config_data=config_data, command='AA', name='AXX', nodelist=nodelist)
        bb = en.ExecutionNode(config_data=config_data, command='BB', name='BXX', nodelist=nodelist)
        cc = en.ExecutionNode(config_data=config_data, command='CC', name='CXX', nodelist=nodelist)

        aa.setSuperCommand(xx)
        bb.setSuperCommand(xx)
        cc.setSuperCommand(xx)

        aa.requestInputSet(xx, aa.receiveInputSet)
        bb.requestInputSet(aa, bb.receiveInputSet)
        cc.requestInputSet(bb, cc.receiveInputSet)
        xx.requestOutputSet(cc, xx.receiveOutputSet)
        
        self.assertEqual(aa.reportStatus(), 'Pending')
        self.assertEqual(bb.reportStatus(), 'Pending')
        self.assertEqual(cc.reportStatus(), 'Pending')
        self.assertEqual(xx.reportStatus(), 'Pending')
                
        ###############
        
        xx.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': None}
        xx.inputSet = xx.inputMap.keys()
        xx.allInputsReceived = True
        aa.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': 1}
        aa.inputSet = aa.inputMap.keys()
        aa.allInputsReceived = True
        bb.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': 1}
        bb.inputSet = bb.inputMap.keys()
        bb.allInputsReceived = True
        cc.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': None}
        cc.inputSet = cc.inputMap.keys()
        cc.allInputsReceived = True
        
        self.assertEqual(aa.reportStatus(), '4 of 4 Inputs Complete')
        self.assertEqual(bb.reportStatus(), '4 of 4 Inputs Complete')
        self.assertEqual(cc.reportStatus(), '3 of 4 Inputs Complete')
        self.assertEqual(xx.reportStatus(), '91% Complete')

    def XXtestReportStatus_8(self):
        inputSet = [
            'abc', 'abc2', 'abc3', 'abc4',
        ]

        nodelist = {}
        xx = en.ExecutionNode(config_data=config_data, command='Script', name='XX', chaining='implicit', nodelist=nodelist)
        aa = en.ExecutionNode(config_data=config_data, command='AA', name='AXX', nodelist=nodelist)
        bb = en.ExecutionNode(config_data=config_data, command='BB', name='BXX', nodelist=nodelist)
        cc = en.ExecutionNode(config_data=config_data, command='CC', name='CXX', nodelist=nodelist)

        aa.setSuperCommand(xx)
        bb.setSuperCommand(xx)
        cc.setSuperCommand(xx)

        aa.requestInputSet(xx, aa.receiveInputSet)
        bb.requestInputSet(aa, bb.receiveInputSet)
        cc.requestInputSet(bb, cc.receiveInputSet)
        xx.requestOutputSet(cc, xx.receiveOutputSet)
        
        self.assertEqual(aa.reportStatus(), 'Pending')
        self.assertEqual(bb.reportStatus(), 'Pending')
        self.assertEqual(cc.reportStatus(), 'Pending')
        self.assertEqual(xx.reportStatus(), 'Pending')
                
        ###############
        
        xx.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': None}
        xx.inputSet = xx.inputMap.keys()
        xx.allInputsReceived = True
        aa.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': 1}
        aa.inputSet = aa.inputMap.keys()
        aa.allInputsReceived = True
        aa.allOutputsSent = True
        bb.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': 1}
        bb.inputSet = bb.inputMap.keys()
        bb.allInputsReceived = True
        bb.allOutputsSent = True
        cc.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': None}
        cc.inputSet = cc.inputMap.keys()
        cc.allInputsReceived = True
        
        self.assertEqual(aa.reportStatus(), '100% Complete')
        self.assertEqual(bb.reportStatus(), '100% Complete')
        self.assertEqual(cc.reportStatus(), '3 of 4 Inputs Complete')
        self.assertEqual(xx.reportStatus(), '91% Complete')

    def XXtestReportStatus_6(self):
        inputSet = [
            'abc', 'abc2', 'abc3', 'abc4',
        ]

        nodelist = {}
        xx = en.ExecutionNode(config_data=config_data, command='Script', name='XX', chaining='implicit', nodelist=nodelist)
        aa = en.ExecutionNode(config_data=config_data, command='AA', name='AXX', nodelist=nodelist)
        bb = en.ExecutionNode(config_data=config_data, command='BB', name='BXX', nodelist=nodelist)
        cc = en.ExecutionNode(config_data=config_data, command='CC', name='CXX', nodelist=nodelist)

        aa.setSuperCommand(xx)
        bb.setSuperCommand(xx)
        cc.setSuperCommand(xx)

        aa.requestInputSet(xx, aa.receiveInputSet)
        bb.requestInputSet(aa, bb.receiveInputSet)
        cc.requestInputSet(bb, cc.receiveInputSet)
        xx.requestOutputSet(cc, xx.receiveOutputSet)
        
        self.assertEqual(aa.reportStatus(), 'Pending')
        self.assertEqual(bb.reportStatus(), 'Pending')
        self.assertEqual(cc.reportStatus(), 'Pending')
        self.assertEqual(xx.reportStatus(), 'Pending')
                
        ###############
        
        xx.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': 1}
        xx.inputSet = xx.inputMap.keys()
        xx.allInputsReceived = True
        xx.allOutputsSent = True
        aa.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': 1}
        aa.inputSet = aa.inputMap.keys()
        aa.allInputsReceived = True
        aa.allOutputsSent = True
        bb.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': 1}
        bb.inputSet = bb.inputMap.keys()
        bb.allInputsReceived = True
        bb.allOutputsSent = True
        cc.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': 1}
        cc.inputSet = cc.inputMap.keys()
        cc.allInputsReceived = True
        cc.allOutputsSent = True
        
        self.assertEqual(aa.reportStatus(), '100% Complete')
        self.assertEqual(bb.reportStatus(), '100% Complete')
        self.assertEqual(cc.reportStatus(), '100% Complete')
        self.assertEqual(xx.reportStatus(), '100% Complete')

    def XXtestReportStatus_9(self):
        inputSet = [
            'abc', 'abc2', 'abc3', 'abc4',
        ]

        nodelist = {}
        xx = en.ExecutionNode(config_data=config_data, command='Script', name='XX', chaining='implicit', nodelist=nodelist)
        aa = en.ExecutionNode(config_data=config_data, command='AA', name='AXX', nodelist=nodelist)
        bb = en.ExecutionNode(config_data=config_data, command='BB', name='BXX', nodelist=nodelist)
        cc = en.ExecutionNode(config_data=config_data, command='CC', name='CXX', nodelist=nodelist)

        aa.setSuperCommand(xx)
        bb.setSuperCommand(xx)
        cc.setSuperCommand(xx)

        aa.requestInputSet(xx, aa.receiveInputSet)
        bb.requestInputSet(aa, bb.receiveInputSet)
        cc.requestInputSet(bb, cc.receiveInputSet)
        xx.requestOutputSet(cc, xx.receiveOutputSet)
        
        self.assertEqual(aa.reportStatus(), 'Pending')
        self.assertEqual(bb.reportStatus(), 'Pending')
        self.assertEqual(cc.reportStatus(), 'Pending')
        self.assertEqual(xx.reportStatus(), 'Pending')
                
        ###############
        
        xx.inputMap = {'abc': 1, 'abc2': None, 'abc3': None, 'abc4': None}
        xx.inputSet = xx.inputMap.keys()
        aa.inputMap = {'abc': 1, 'abc2': 1, 'abc3': 1, 'abc4': None}
        aa.inputSet = aa.inputMap.keys()
        bb.inputMap = {'abc': 1, 'abc2': 1, 'abc3': None, 'abc4': None}
        bb.inputSet = bb.inputMap.keys()
        cc.inputMap = {'abc': 1, 'abc2': 1, 'abc3': None, 'abc4': None}
        cc.inputSet = cc.inputMap.keys()
        
        self.assertEqual(aa.reportStatus(), 'Processed 3 Inputs')
        self.assertEqual(bb.reportStatus(), 'Processed 2 Inputs')
        self.assertEqual(cc.reportStatus(), 'Processed 2 Inputs')
        self.assertEqual(xx.reportStatus(), '20% Complete')
                
        
        
    def XXtestReportStatus_1(self):
        inputSet = [
            'abc', 'abc2', 'abc3', 'abc4',
        ]

        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX')

        self.assertEqual(xx.reportStatus(), 'Pending')
                
        for i in range(len(inputSet)):
            xx.receiveInputItem(inputSet[i], xx)
            
            self.assertEqual(xx.reportStatus(), "Processed 0 Inputs")
            
        xx.receiveInputSet([])
        
        self.assertEqual(xx.reportStatus(), '0 of %s Inputs Complete' % len(inputSet))

        for i in range(len(inputSet)):
            xx.inputMap[inputSet[i]] = i+15
            
            if i <= len(inputSet):
                self.assertEqual(xx.reportStatus(), "%s of %s Inputs Complete" % (i+1, len(inputSet)))
            else:
                self.assertEqual(xx.reportStatus(), "100% Complete")
        
        self.assertEqual(xx.reportStatus(), "%s of %s Inputs Complete" % (len(inputSet), len(inputSet)))
        
        xx.allOutputsSent = True
        
        self.assertEqual(xx.reportStatus(), "100% Complete")
        
        
    def XXtestReceiveStatus(self):
        import mandiant.windtalker.payload as payload
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX')
        self.assertEqual(xx.commandStatus, False)

        status_strings = ["100% Complete", "1 of 100 Completed", "Processing Step 1 of 5", "Processed 200 Inputs"]
        
        for status_string in status_strings:
            msg = payload.SimpleMessage(msgid=1,
                                        queue='abc',
                                        message=yaml.safe_dump({'status': status_string}),
                                       )
            
            xx.receiveStatus(msg)
            self.assertEqual(xx.commandStatus, status_string)
        
        
    def XXtestInputSetCallback(self):
        self.timeout= 5
        
        nodelist = {}
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)
        
        yy_val = "ABC"
        self.xx_val = None
                
        def XX(qq, sourceNode=None):
            global xx_val
            self.xx_val = qq
        
        XX('yy')
        self.assertEqual(self.xx_val, 'yy')
        
        xx.requestInputSet(yy, XX)
        
        self.assertEqual(1, len(yy.inputSetListeners.keys()))
        self.assertEqual(0, len(yy.inputItemListeners.keys()))
        self.assertEqual(0, len(yy.outputItemListeners.keys()))
        self.assertEqual(0, len(yy.outputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputSetListeners.keys()))
        
        self.assertIn(xx.id, yy.inputSetListeners.keys())
        self.assertIn(XX, yy.inputSetListeners.values())
        self.assertEqual(XX, yy.inputSetListeners[xx.id])
        
        
        yy.receiveInputSet(yy_val)
        
        self.assertEqual(self.xx_val[0], yy_val)


    def XXtestInputItemCallback(self):
        self.timeout= 5
        
        nodelist = {}
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)
        
        yy_val = "ABC"
        self.xx_val = None
                
        def XX(qq, sourceNode=None):
            global xx_val
            self.xx_val = qq
        
        XX('yy')
        self.assertEqual(self.xx_val, 'yy')
        
        xx.requestInputItem(yy, XX)
        
        self.assertEqual(0, len(yy.inputSetListeners.keys()))
        self.assertEqual(1, len(yy.inputItemListeners.keys()))
        self.assertEqual(0, len(yy.outputItemListeners.keys()))
        self.assertEqual(0, len(yy.outputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputSetListeners.keys()))
        
        self.assertIn(xx.id, yy.inputItemListeners.keys())
        self.assertIn(XX, yy.inputItemListeners.values())
        self.assertEqual(XX, yy.inputItemListeners[xx.id])
        
        yy.receiveInputItem(yy_val, sourceNode=yy)
        
        self.assertEqual(self.xx_val, yy_val)


    def XXtestOutputSetCallback(self):
        self.timeout= 5
        
        nodelist = {}
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)
        
        yy_val = "ABC"
        self.xx_val = None
                
        def XX(qq, sourceNode=None):
            global xx_val
            self.xx_val = qq
        
        XX('yy')
        self.assertEqual(self.xx_val, 'yy')
        
        xx.requestOutputSet(yy, XX)
        
        self.assertEqual(0, len(yy.inputSetListeners.keys()))
        self.assertEqual(0, len(yy.inputItemListeners.keys()))
        self.assertEqual(0, len(yy.outputItemListeners.keys()))
        self.assertEqual(1, len(yy.outputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputSetListeners.keys()))
        
        self.assertIn(xx.id, yy.outputSetListeners.keys())
        self.assertIn(XX, yy.outputSetListeners.values())
        self.assertEqual(XX, yy.outputSetListeners[xx.id])
        
        yy.receiveOutputSet(yy_val)
        
        self.assertEqual(self.xx_val, yy_val)


    def XXtestOutputItemCallback(self):
        self.timeout= 5
        
        nodelist = {}
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)
        
        yy_val = "ABC"
        self.xx_val = None
                
        def XX(qq, sourceNode=None):
            global xx_val
            self.xx_val = qq
        
        XX('yy')
        self.assertEqual(self.xx_val, 'yy')
        
        xx.requestOutputItem(yy, XX)
        
        self.assertEqual(0, len(yy.inputSetListeners.keys()))
        self.assertEqual(0, len(yy.inputItemListeners.keys()))
        self.assertEqual(1, len(yy.outputItemListeners.keys()))
        self.assertEqual(0, len(yy.outputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputSetListeners.keys()))
        
        self.assertIn(xx.id, yy.outputItemListeners.keys())
        self.assertIn(XX, yy.outputItemListeners.values())
        self.assertEqual(XX, yy.outputItemListeners[xx.id])
        
        yy.receiveOutputItem(yy_val, sourceNode=yy)
        
        self.assertEqual(self.xx_val, yy_val)


    def XXtestRequestInputSet(self):
        self.timeout= 5
        
        nodelist = {}
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)
        
        def XX():
            pass
        
        xx.requestInputSet(yy, XX)
        
        self.assertEqual(1, len(yy.inputSetListeners.keys()))
        self.assertEqual(0, len(yy.inputItemListeners.keys()))
        self.assertEqual(0, len(yy.outputItemListeners.keys()))
        self.assertEqual(0, len(yy.outputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputSetListeners.keys()))
        
        self.assertIn(xx.id, yy.inputSetListeners.keys())
        self.assertIn(XX, yy.inputSetListeners.values())
        self.assertEqual(XX, yy.inputSetListeners[xx.id])


    def XXtestRequestInputItem(self):
        self.timeout= 5
        
        nodelist = {}
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)
        
        def XX():
            pass
        
        xx.requestInputItem(yy, XX)
        
        self.assertEqual(0, len(yy.inputSetListeners.keys()))
        self.assertEqual(1, len(yy.inputItemListeners.keys()))
        self.assertEqual(0, len(yy.outputItemListeners.keys()))
        self.assertEqual(0, len(yy.outputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputSetListeners.keys()))
        
        self.assertIn(xx.id, yy.inputItemListeners.keys())
        self.assertIn(XX, yy.inputItemListeners.values())
        self.assertEqual(XX, yy.inputItemListeners[xx.id])


    def XXtestRequestOutputItem(self):
        self.timeout= 5
        
        nodelist = {}
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)
        
        def XX():
            pass
        
        xx.requestOutputItem(yy, XX)
        
        self.assertEqual(0, len(yy.inputSetListeners.keys()))
        self.assertEqual(0, len(yy.inputItemListeners.keys()))
        self.assertEqual(1, len(yy.outputItemListeners.keys()))
        self.assertEqual(0, len(yy.outputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputSetListeners.keys()))
        
        self.assertIn(xx.id, yy.outputItemListeners.keys())
        self.assertIn(XX, yy.outputItemListeners.values())
        self.assertEqual(XX, yy.outputItemListeners[xx.id])


    def XXtestRequestOutputSet(self):
        self.timeout= 5
        
        nodelist = {}
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)
        
        def XX():
            pass
        
        xx.requestOutputSet(yy, XX)
        
        self.assertEqual(0, len(yy.inputSetListeners.keys()))
        self.assertEqual(0, len(yy.inputItemListeners.keys()))
        self.assertEqual(0, len(yy.outputItemListeners.keys()))
        self.assertEqual(1, len(yy.outputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputSetListeners.keys()))
        self.assertEqual(0, len(xx.inputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputItemListeners.keys()))
        self.assertEqual(0, len(xx.outputSetListeners.keys()))
        
        self.assertIn(xx.id, yy.outputSetListeners.keys())
        self.assertIn(XX, yy.outputSetListeners.values())
        self.assertEqual(XX, yy.outputSetListeners[xx.id])


    def XXtestSub(self):
        self.timeout= 5
        
        nodelist = {}
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)
        
        xx.setSubCommand(yy)
        
        self.assertEqual(1, len(yy.supercommands))
        self.assertEqual(0, len(xx.supercommands))
        self.assertEqual(0, len(yy.subcommands))
        self.assertEqual(1, len(xx.subcommands))
        self.assertIn(yy.id, xx.subcommands)
        self.assertIn(xx.id, yy.supercommands)


    def XXtestSuper(self):
        self.timeout= 5
        
        nodelist = {}
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)
        
        yy.setSuperCommand(xx)
        
        self.assertEqual(1, len(yy.supercommands))
        self.assertEqual(0, len(xx.supercommands))
        self.assertEqual(0, len(yy.subcommands))
        self.assertEqual(1, len(xx.subcommands))
        self.assertIn(yy.id, xx.subcommands)
        self.assertIn(xx.id, yy.supercommands)
        
    def XXtestParent(self):
        self.timeout= 5
        
        nodelist = {}
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)
        
        xx.setParent(yy)
        
        self.assertEqual(1, len(yy.children))
        self.assertEqual(0, len(xx.children))
        self.assertEqual(0, len(yy.parents))
        self.assertEqual(1, len(xx.parents))
        self.assertIn(yy.id, xx.parents)
        self.assertIn(xx.id, yy.children)


    def XXtestChild(self):
        self.timeout= 5
        
        nodelist = {}
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX', nodelist=nodelist)
        yy = en.ExecutionNode(config_data=config_data, command='B', name='YY', nodelist=nodelist)
        
        yy.setChild(xx)
        
        self.assertEqual(1, len(yy.children))
        self.assertEqual(0, len(xx.children))
        self.assertEqual(0, len(yy.parents))
        self.assertEqual(1, len(xx.parents))
        self.assertIn(yy.id, xx.parents)
        self.assertIn(xx.id, yy.children)


    def XXtestParseStatus(self):
        statuses = {
            "100% Complete": 100,
            "5 of 10 Units Complete": 50,
            "Processing Step 3 of 4": 75,
            "Processed 45 Records": 20,
            "Pending": 0,
            "done": "Invalid Status Format",
            "10 of 10 Records Complete": 100,
            "5 of 10 Units Complete (Stalled)": 50,
            "Processing Step 3 of 4 (Stalled)": 75,
            "Processed 45 Records (Stalled)": 20,
        }
        
        xx = en.ExecutionNode(config_data=config_data, command='A', name='XX')
        
        for status in statuses:
            res = xx._parseStatus(status)
            
            self.assertEqual(res, statuses[status])
            
    
    def XXtestTraceIOPaths_1(self):
        self.timeout = 5                # Set a reasonable timeout

        ######
        job_script = file(database + "data/job_scripts/implicit_chaining_1.xml").read()

        dom = minidom.parseString(job_script)
        
        firstNode = dom.childNodes[0]
        
        basenode = en.processScript(firstNode, config_data=config_data)
        
        nodeMap = {}
        commandMap = {}
        
        for t_node in basenode.allnodes:
            nodeMap[t_node] = basenode.getNameByNodeID(t_node)
            commandMap[nodeMap[t_node]] = t_node

        iopath = basenode.traceIOPaths()
        
        self.assertEqual(len(iopath), 4)
        self.assertEqual(iopath[0], commandMap['C1'])
        self.assertEqual(iopath[1], commandMap['C2'])
        self.assertEqual(iopath[2], commandMap['C3'])
        self.assertEqual(iopath[3], commandMap['C4'])
        
    def XXtestParsingImplicit_1(self):
        """Parsing script doc into executionNode tree."""
        self.timeout = 5                # Set a reasonable timeout

        ######
        job_script = file(database + "data/job_scripts/implicit_chaining_1.xml").read()

        dom = minidom.parseString(job_script)
        
        firstNode = dom.childNodes[0]
        
        basenode = en.processScript(firstNode, config_data=config_data)
        
        nodeMap = {}
        commandMap = {}
        
        for t_node in basenode.allnodes:
            nodeMap[t_node] = basenode.getNameByNodeID(t_node)
            commandMap[nodeMap[t_node]] = t_node

        #basenode.dumpNodeGraph()
        
        #print(basenode.getNodeByNodeID(commandMap['C1']).script)
        
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
        

   
    def testParsingStreaming_1(self):
        """Parsing script doc into executionNode tree."""
        self.timeout = 5                # Set a reasonable timeout

        ######
        job_script = file(database + "data/job_scripts/streaming_inputs_1.xml").read()

        dom = minidom.parseString(job_script)
        
        firstNode = dom.childNodes[0]
        
        basenode = en.processScript(firstNode, config_data=config_data)
        
        nodeMap = {}
        commandMap = {}
        
        for t_node in basenode.allnodes:
            nodeMap[t_node] = basenode.getNameByNodeID(t_node)
            commandMap[nodeMap[t_node]] = t_node

        basenode.dumpNodeGraph()
        
        print(basenode.getNodeByNodeID(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94']).script)
        
        # Sup/Super    
        self.assertEqual(2, len(basenode.subcommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84']).supercommands))
        self.assertEqual(0, len(basenode.supercommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84']).subcommands))
        self.assertIn(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94'], basenode.subcommands)
        self.assertIn(commandMap['urn:uuid:0b44d8a0-7ec5-4de5-9d08-61c72aacbb35'], basenode.getNodeByNodeID(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94']).supercommands)
        self.assertIn(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84'], basenode.subcommands)
        self.assertIn(commandMap['urn:uuid:0b44d8a0-7ec5-4de5-9d08-61c72aacbb35'], basenode.getNodeByNodeID(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84']).supercommands)

        # Parent/Child
        self.assertEqual(0, len(basenode.parents))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84']).parents))
        self.assertEqual(0, len(basenode.children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94']).children))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84']).children))
        self.assertIn(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94'], basenode.getNodeByNodeID(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84']).parents)
        self.assertIn(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84'], basenode.getNodeByNodeID(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94']).children)

        
        # InputListeners/OutputListeners
        self.assertEqual(0, len(basenode.inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84']).inputItemListeners.keys()))
        self.assertEqual(1, len(basenode.inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.outputItemListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.outputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84']).outputSetListeners.keys()))
        self.assertIn(commandMap['urn:uuid:0b44d8a0-7ec5-4de5-9d08-61c72aacbb35'], basenode.getNodeByNodeID(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84']).outputSetListeners.keys())
        self.assertIn(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94'], basenode.getNodeByNodeID(commandMap['urn:uuid:0b44d8a0-7ec5-4de5-9d08-61c72aacbb35']).inputSetListeners.keys())
        self.assertIn(commandMap['urn:uuid:b6a49136-7ee7-4d8a-9cc4-511ee7f17b84'], basenode.getNodeByNodeID(commandMap['urn:uuid:3f50fd6d-3f11-4b7a-a06c-b17e015a7c94']).outputItemListeners.keys())
        

   
    def XXtestTraceIOPaths_2(self):
        """Parsing script doc into executionNode tree."""
        self.timeout = 5                # Set a reasonable timeout

        ######
        job_script = file(database + "data/job_scripts/implicit_chaining_2.xml").read()

        dom = minidom.parseString(job_script)
        
        firstNode = dom.childNodes[0]
        
        basenode = en.processScript(firstNode, config_data=config_data)
        
        nodeMap = {}
        commandMap = {}
        
        for t_node in basenode.allnodes:
            nodeMap[t_node] = basenode.getNameByNodeID(t_node)
            commandMap[nodeMap[t_node]] = t_node

        iopath = basenode.getNodeByName("S1").traceIOPaths()
        
        self.assertEqual(len(iopath), 1)
        self.assertEqual(len(iopath[0]), 3)
        self.assertIn(commandMap['C1'], iopath[0])
        self.assertIn(commandMap['C2'], iopath[0])
        self.assertIn(commandMap['C3'], iopath[0])
        
        iopath = basenode.getNodeByName("S2").traceIOPaths()
        
        self.assertEqual(len(iopath), 3)
        self.assertEqual(commandMap['C8'], iopath[0])
        self.assertEqual(commandMap['C9'], iopath[1])
        self.assertEqual(commandMap['C10'], iopath[2])
        
        iopath = basenode.traceIOPaths()
        
        self.assertEqual(len(iopath), 6)
        self.assertEqual(iopath[0], commandMap['C7'])
        self.assertEqual(iopath[1], commandMap['S1'])
        self.assertEqual(iopath[2], commandMap['C4'])
        self.assertEqual(iopath[3], commandMap['S2'])
        self.assertEqual(iopath[4], commandMap['C5'])
        self.assertEqual(iopath[5], commandMap['C6'])

    
    def XXtestParsingFBomb_1(self):
        """Parsing script doc into executionNode tree."""
        self.timeout = 5                # Set a reasonable timeout

        ######
        job_script = file(database + "data/job_scripts/fbomb_1.xml").read()

        dom = minidom.parseString(job_script)
        
        firstNode = dom.childNodes[0]
        
        basenode = en.processScript(firstNode, config_data=config_data)
        
        nodeMap = {}
        commandMap = {}
        
        for t_node in basenode.allnodes:
            nodeMap[t_node] = basenode.getNameByNodeID(t_node)
            commandMap[nodeMap[t_node]] = t_node

        #basenode.dumpNodeGraph()
        
        
    def XXtestParsingImplicit_2(self):
        """Parsing script doc into executionNode tree."""
        self.timeout = 5                # Set a reasonable timeout

        ######
        job_script = file(database + "data/job_scripts/implicit_chaining_2.xml").read()

        dom = minidom.parseString(job_script)
        
        firstNode = dom.childNodes[0]
        
        basenode = en.processScript(firstNode, config_data=config_data)
        
        nodeMap = {}
        commandMap = {}
        
        for t_node in basenode.allnodes:
            nodeMap[t_node] = basenode.getNameByNodeID(t_node)
            commandMap[nodeMap[t_node]] = t_node

        #basenode.dumpNodeGraph()
        
        # Sup/Super    
        self.assertEqual(0, len(basenode.supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C1']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C2']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C3']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C4']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C5']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C6']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C7']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C8']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C9']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C10']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['S1']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['S2']).supercommands))
        self.assertEqual(6, len(basenode.subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C1']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C2']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C3']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C4']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C5']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C6']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C7']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C8']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C9']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C10']).subcommands))
        self.assertEqual(3, len(basenode.getNodeByNodeID(commandMap['S1']).subcommands))
        self.assertEqual(3, len(basenode.getNodeByNodeID(commandMap['S2']).subcommands))
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['C7']).supercommands)
        self.assertIn(commandMap['S2'], basenode.getNodeByNodeID(commandMap['C8']).supercommands)
        self.assertIn(commandMap['S2'], basenode.getNodeByNodeID(commandMap['C9']).supercommands)
        self.assertIn(commandMap['S2'], basenode.getNodeByNodeID(commandMap['C10']).supercommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['C5']).supercommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['C6']).supercommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['S2']).supercommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['S1']).supercommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['C4']).supercommands)
        self.assertIn(commandMap['S1'], basenode.getNodeByNodeID(commandMap['C1']).supercommands)
        self.assertIn(commandMap['S1'], basenode.getNodeByNodeID(commandMap['C3']).supercommands)
        self.assertIn(commandMap['S1'], basenode.getNodeByNodeID(commandMap['C2']).supercommands)
        
        self.assertIn(commandMap['C8'], basenode.getNodeByNodeID(commandMap['S2']).subcommands)
        self.assertIn(commandMap['C9'], basenode.getNodeByNodeID(commandMap['S2']).subcommands)
        self.assertIn(commandMap['C10'], basenode.getNodeByNodeID(commandMap['S2']).subcommands)
        self.assertIn(commandMap['C1'], basenode.getNodeByNodeID(commandMap['S1']).subcommands)
        self.assertIn(commandMap['C2'], basenode.getNodeByNodeID(commandMap['S1']).subcommands)
        self.assertIn(commandMap['C3'], basenode.getNodeByNodeID(commandMap['S1']).subcommands)
        self.assertIn(commandMap['C7'], basenode.subcommands)
        self.assertIn(commandMap['S1'], basenode.subcommands)
        self.assertIn(commandMap['C4'], basenode.subcommands)
        self.assertIn(commandMap['S2'], basenode.subcommands)
        self.assertIn(commandMap['C5'], basenode.subcommands)
        self.assertIn(commandMap['C6'], basenode.subcommands)

        # Parent/Child
        self.assertEqual(0, len(basenode.parents))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C1']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C2']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C3']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C4']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C5']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C6']).parents))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C7']).parents))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C8']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C9']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C10']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['S1']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['S2']).parents))
        self.assertEqual(0, len(basenode.children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C1']).children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C2']).children))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C3']).children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C4']).children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C5']).children))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C6']).children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C7']).children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C8']).children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C9']).children))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C10']).children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['S1']).children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['S2']).children))
        self.assertIn(commandMap['C7'], basenode.getNodeByNodeID(commandMap['S1']).parents)
        self.assertIn(commandMap['C4'], basenode.getNodeByNodeID(commandMap['S2']).parents)
        self.assertIn(commandMap['C9'], basenode.getNodeByNodeID(commandMap['C10']).parents)
        self.assertIn(commandMap['C8'], basenode.getNodeByNodeID(commandMap['C9']).parents)
        self.assertIn(commandMap['S1'], basenode.getNodeByNodeID(commandMap['C4']).parents)
        self.assertIn(commandMap['C1'], basenode.getNodeByNodeID(commandMap['C2']).parents)
        self.assertIn(commandMap['C2'], basenode.getNodeByNodeID(commandMap['C3']).parents)
        self.assertIn(commandMap['S2'], basenode.getNodeByNodeID(commandMap['C5']).parents)
        self.assertIn(commandMap['C5'], basenode.getNodeByNodeID(commandMap['C6']).parents)
        
        self.assertIn(commandMap['C4'], basenode.getNodeByNodeID(commandMap['S1']).children)
        self.assertIn(commandMap['C5'], basenode.getNodeByNodeID(commandMap['S2']).children)
        self.assertIn(commandMap['C10'], basenode.getNodeByNodeID(commandMap['C9']).children)
        self.assertIn(commandMap['S2'], basenode.getNodeByNodeID(commandMap['C4']).children)
        self.assertIn(commandMap['C3'], basenode.getNodeByNodeID(commandMap['C2']).children)
        self.assertIn(commandMap['S1'], basenode.getNodeByNodeID(commandMap['C7']).children)
        self.assertIn(commandMap['C2'], basenode.getNodeByNodeID(commandMap['C1']).children)
        self.assertIn(commandMap['C6'], basenode.getNodeByNodeID(commandMap['C5']).children)
        self.assertIn(commandMap['C9'], basenode.getNodeByNodeID(commandMap['C8']).children)

        
        # InputListeners/OutputListeners
        self.assertEqual(0, len(basenode.inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C1']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C2']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C3']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C4']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C5']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C6']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C7']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C8']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C9']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C10']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['S1']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['S2']).inputItemListeners.keys()))
        self.assertEqual(1, len(basenode.inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C1']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C2']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C3']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C4']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C5']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C6']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C7']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C8']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C9']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C10']).inputSetListeners.keys()))
        self.assertEqual(3, len(basenode.getNodeByNodeID(commandMap['S1']).inputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['S2']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C1']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C2']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C3']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C4']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C5']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C6']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C7']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C8']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C9']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['C10']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['S1']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['S2']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C1']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C2']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C3']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C4']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C5']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C6']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C7']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C8']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C9']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['C10']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['S1']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['S2']).outputSetListeners.keys()))
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['C6']).outputSetListeners.keys())
        self.assertIn(commandMap['C9'], basenode.getNodeByNodeID(commandMap['C8']).outputSetListeners.keys())
        self.assertIn(commandMap['C6'], basenode.getNodeByNodeID(commandMap['C5']).outputSetListeners.keys())
        self.assertIn(commandMap['S1'], basenode.getNodeByNodeID(commandMap['C1']).outputSetListeners.keys())
        self.assertIn(commandMap['S1'], basenode.getNodeByNodeID(commandMap['C7']).outputSetListeners.keys())
        self.assertIn(commandMap['S1'], basenode.getNodeByNodeID(commandMap['C3']).outputSetListeners.keys())
        self.assertIn(commandMap['S1'], basenode.getNodeByNodeID(commandMap['C2']).outputSetListeners.keys())
        self.assertIn(commandMap['S2'], basenode.getNodeByNodeID(commandMap['C4']).outputSetListeners.keys())
        self.assertIn(commandMap['C10'], basenode.getNodeByNodeID(commandMap['C9']).outputSetListeners.keys())
        self.assertIn(commandMap['S2'], basenode.getNodeByNodeID(commandMap['C10']).outputSetListeners.keys())
        self.assertIn(commandMap['C5'], basenode.getNodeByNodeID(commandMap['S2']).outputSetListeners.keys())
        self.assertIn(commandMap['C4'], basenode.getNodeByNodeID(commandMap['S1']).outputSetListeners.keys())

        self.assertIn(commandMap['C7'], basenode.getNodeByNodeID(commandMap['S0']).inputSetListeners.keys())
        self.assertIn(commandMap['C8'], basenode.getNodeByNodeID(commandMap['S2']).inputSetListeners.keys())
        self.assertIn(commandMap['C1'], basenode.getNodeByNodeID(commandMap['S1']).inputSetListeners.keys())
        self.assertIn(commandMap['C2'], basenode.getNodeByNodeID(commandMap['S1']).inputSetListeners.keys())
        self.assertIn(commandMap['C3'], basenode.getNodeByNodeID(commandMap['S1']).inputSetListeners.keys())
        


    def XXtestParsingExplicit(self):
        """Parsing script doc into executionNode tree."""
        self.timeout = 5                # Set a reasonable timeout

        ######
        job_script = file(database + "data/job_scripts/explicit_chaining_1.xml").read()

        dom = minidom.parseString(job_script)
        
        firstNode = dom.childNodes[0]
        
        basenode = en.processScript(firstNode, config_data=config_data)
        
        nodeMap = {}
        commandMap = {}
        
        for t_node in basenode.allnodes:
            nodeMap[t_node] = basenode.getNameByNodeID(t_node)
            commandMap[nodeMap[t_node]] = t_node

        #basenode.dumpNodeGraph()
        
        # Sup/Super    
        self.assertEqual(4, len(basenode.subcommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:0']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:1']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:3']).supercommands))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:2']).supercommands))
        self.assertEqual(0, len(basenode.supercommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:0']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:1']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:3']).subcommands))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:2']).subcommands))
        self.assertIn(commandMap['urn:0'], basenode.subcommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['urn:0']).supercommands)
        self.assertIn(commandMap['urn:1'], basenode.subcommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['urn:1']).supercommands)
        self.assertIn(commandMap['urn:3'], basenode.subcommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['urn:3']).supercommands)
        self.assertIn(commandMap['urn:2'], basenode.subcommands)
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['urn:2']).supercommands)

        # Parent/Child
        self.assertEqual(0, len(basenode.parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:0']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:1']).parents))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:2']).parents))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:3']).parents))
        self.assertEqual(0, len(basenode.children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:0']).children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:1']).children))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:2']).children))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:3']).children))
        self.assertIn(commandMap['urn:0'], basenode.getNodeByNodeID(commandMap['urn:1']).parents)
        self.assertIn(commandMap['urn:2'], basenode.getNodeByNodeID(commandMap['urn:0']).parents)
        self.assertIn(commandMap['urn:1'], basenode.getNodeByNodeID(commandMap['urn:3']).parents)
        self.assertIn(commandMap['urn:1'], basenode.getNodeByNodeID(commandMap['urn:0']).children)
        self.assertIn(commandMap['urn:3'], basenode.getNodeByNodeID(commandMap['urn:1']).children)
        self.assertIn(commandMap['urn:0'], basenode.getNodeByNodeID(commandMap['urn:2']).children)

        
        # InputListeners/OutputListeners
        self.assertEqual(0, len(basenode.inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:0']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:1']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:2']).inputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:3']).inputItemListeners.keys()))
        self.assertEqual(1, len(basenode.inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:0']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:1']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:2']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:3']).inputSetListeners.keys()))
        self.assertEqual(0, len(basenode.outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:0']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:1']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:2']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.getNodeByNodeID(commandMap['urn:3']).outputItemListeners.keys()))
        self.assertEqual(0, len(basenode.outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:0']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:1']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:2']).outputSetListeners.keys()))
        self.assertEqual(1, len(basenode.getNodeByNodeID(commandMap['urn:3']).outputSetListeners.keys()))
        self.assertIn(commandMap['urn:2'], basenode.getNodeByNodeID(commandMap['urn:1']).outputSetListeners.keys())
        self.assertIn(commandMap['urn:3'], basenode.getNodeByNodeID(commandMap['urn:2']).outputSetListeners.keys())
        self.assertIn(commandMap['urn:1'], basenode.getNodeByNodeID(commandMap['urn:0']).outputSetListeners.keys())
        self.assertIn(commandMap['S0'], basenode.getNodeByNodeID(commandMap['urn:3']).outputSetListeners.keys())
        self.assertIn(commandMap['urn:0'], basenode.getNodeByNodeID(commandMap['S0']).inputSetListeners.keys())
