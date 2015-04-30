# Python Modules
import tempfile,re,yaml,datetime
import xml.dom.minidom as minidom
# Framework Modules
import twisted.web2.resource as resource
from twisted.internet import reactor, defer
from twisted.python import log, failure

import mandiant.utils.call_trace as call_trace
import mandiant.windtalker.util as wtutil
import mandiant.timekeeper.timekeeper as timekeeper

# Mir Modules
import mir.config as config
import mir.models.interface.connector.message_bus as mbc
import mir.models.interface as interface
import mir.models.models2 as models
import mir.identity as identity
import mir.util.dtutil as mir_datetime
import mir.script_runner.execution_node as execution_node
import mir.util.issues as isu
import mir.error_messages as mir_err
from mir.file_service.file_provider import FileProvider

# load the config for this service
config_data = config.MirConfig("scriptrunner")
config_data.loadServiceConfig('mir_web')
config_data.loadServiceConfig('agent_dispatcher')
config_data.loadServiceConfig('analyzer_dispatcher')

MND_error_message_code = 'SCR'
MND_error_messages = {
    'a4c2507a-6ca6-448f-84c5-7bdf0aacc57d': {'msg': 'Script Runner: Received message to kick off queue %(queue_ident)s', 'args': {'level': 'info'}},
    'f6df4220-be64-4d2c-aa2e-f36e154f65d3': {'msg': 'Script Runner: Unable to retrieve queued jobs for %(queued_job_ident)s.  Maybe no jobs attached to this queue.', 'args': {'level': 'minor'}},
    'be6287b9-dbf7-4e06-9242-a5221189a8c1': {'msg': 'Script Runner: Checking to see if we should kick off queuedjob: %(queued_job_ident)s', 'args': {'level': 'info'}},
    '040045cc-7f8b-4061-8121-a87c312b7bff': {'msg': 'Script Runner: Queuedjob %(queued_job_ident)s is already running... skipping', 'args': {'level': 'info'}},
    '5704f819-87b4-4fd6-a666-bc41415d15c9': {'msg': 'Script Runner: Unable to retrieve Job record for QueuedJob %(queued_job_ident)s; Skipping this QueuedJob.', 'args': {'level': 'major'}},
    '750b1d1a-4875-4f8d-8444-d3f41b49df03': {'msg': 'Script Runner: Deleting queuedjob %(queued_job_ident)s because its delete_after is before now.', 'args': {'level': 'info'}},
    '1088ceec-896c-4a8e-8c70-381ff04b6633': {'msg': 'Script Runner: Actually kicking off queuedjob: %(queued_job_ident)s', 'args': {'level': 'info'}},
    '13c515ff-7401-4eb9-8b01-51559b9398db': {'msg': 'Script Runner: Setting queuedjob %(queued_job_ident)s delete_after property to %(currtime)s because it is non-recurring.', 'args': {'level': 'info'}},
    '8e0abd33-900c-4b49-8ac2-55088151fb11': {'msg': 'Script Runner: Updating queuedjob: %(queued_job_ident)s', 'args': {'level': 'info'}},
    '7b9bc8d4-6a86-46b3-876b-0a337f12974e': {'msg': 'Script Runner: Not actually kicking off queuedjob: %(queued_job_ident)s', 'args': {'level': 'info'}},
    'bee5922d-6030-45fa-a5f2-e704241f467b': {'msg': 'Script Runner: In initiate method for queuedjob: %(queued_job_ident)s running job %(job_ident)s.', 'args': {'level': 'info'}},
    'f0f4ee71-49a1-4d83-81cb-248657441d9a': {'msg': 'Script Runner: Relaying cancel %(ident)s to queue %(queue_ident)s for user %(user)s.', 'args': {'level': 'minor'}},
    'c175ca2a-dd0c-4c22-8543-addf466fa771': {'msg': 'Script Runner: Created result set %(resultset_ident)s for job %(job_ident)s', 'args': {'level': 'info'}},
    '94f8cdb0-d3a0-4c7a-a8b6-03c99246706a': {'msg': 'Script Runner: Error retrieving database object %(resource_ident)s: %(error_message)s', 'args': {'level': 'minor'}},
    '50c74768-2159-4bc5-85a2-3316eed8a507': {'msg': 'Script Runner: Set status %(ident)s = %(state)s', 'args': {'level': 'info'}},
    'cc8e269a-7e19-4806-848f-32abd884b06e': {'msg': 'Script Runner: Unexpected error setting status on %(ident)s.  Ignored.', 'args': {'level': 'minor'}},
    '5cfef21c-aa91-4a8c-a836-466f08f62ced': {'msg': 'Script Runner: Blocked processing of queue %(ident)s.  Queue processing still in progress from previous kickoff attempt.', 'args': {'level': 'major'}},
}

[MND_error_messages[x_err_msg].update({'code': MND_error_message_code}) for x_err_msg in MND_error_messages]


# The AgentController class concerns itself with the business of working through
# AgentManager communications.  Attempting to keep the communications mechanisms
# out of the mix - this class processes the input it receives from various sources
# and sets the communications classes up with the data they need in order to 
# request/submit data to the service that needs it.
class ScriptRunner(resource.Resource):
    agent_string = "MiR_Script_Runner"
    status_interval = 20
    stats_timeout = 60
    
    # Test created - mir.script_runner.test.test_script_runner.testInit()
    #                mir.script_runner.test.test_script_runner_with_db.testInit()
    #
    # ScriptRunner.__init__: 
    # Purpose in life: Set up the newly created object so that it can function as it 
    # needs to: to collect data from agents.
    def __init__(self, *args, **kwargs):
        resource.Resource.__init__(self)
        self.debug_level = kwargs.has_key("debug_level") and kwargs["debug_level"] or 0
        self.mbus        = kwargs.has_key("mbus") and kwargs["mbus"] or False
        self.configs     = kwargs.has_key("configs") and kwargs["configs"] or {}
        self.active_jobs = []
        self.err_msgs    = mir_err.MIR_Error_Messages(MND_error_message_code, log.msg)
        self.in_process_queues = {}

        # Register the following queues.
        if self.mbus:
            self.mbus.add_queue(config_data.getByPath('script_runner', 'queues', 'basequeue'), self.initiate)
            self.mbus.add_queue(config_data.getByPath('script_runner', 'queues', 'configqueue'), self.config)
            self.mbus.add_queue(config_data.getByPath('script_runner', 'queues', 'runqueue'), self.startQueue)
            self.mbus.add_queue(config_data.getByPath('script_runner', 'queues', 'cancelqueue'), self.cancel)
            
        # init database connection
        data_connector = kwargs.get('dataConnector', None)
        if not data_connector:
            squeue = config_data.getByPath('service_names', 'data_service')
            ident = wtutil.makeIdentity(self.mbus.service_id)
            data_connector = mbc.MessageBusConnector(ident, squeue, self.mbus)
        self.mir = interface.Mir(connector=data_connector)
        
        # init file provider
        self.filep = kwargs.get('fileProvider', None)
        if not self.filep:
            self.filep = FileProvider()
        
        self.active_qjs = {}
                
        if kwargs.has_key("testing") and kwargs["testing"]:
            self.testing = True
        else:
            self.testing = False
            
        self.statsTimer = None

    # Test created - mir.script_runner.test.test_script_runner.testConfig_*()
    #                mir.script_runner.test.test_script_runner_with_db.testConfig_*()
    #
    # ScriptRunner.config
    # Purpose in life:  Receive configuration updates
    def config(self, message, std_callbacks={}):
        result = yaml.safe_load(message._message)
        self.configs = result['configs']


    # Test created - mir.script_runner.test.test_script_runner.testNewJob_*()
    #                mir.script_runner.test.test_script_runner_with_db.testNewJob_*()
    #
    # ScriptRunner.newJob
    # Purpose in life:  Receive a request to kick off a job.
    @defer.inlineCallbacks
    def startQueue(self, message, std_callbacks={}):
        result = yaml.safe_load(message._message)

        self.err_msgs.render_log_msg('a4c2507a-6ca6-448f-84c5-7bdf0aacc57d', {'queue_ident': result['queue_ident']})
        
        # defend against re-entrancy for a specific queue
        if self.in_process_queues.has_key(result['queue_ident']) and self.in_process_queues[result['queue_ident']]:
            self.err_msgs.render_log_msg('5cfef21c-aa91-4a8c-a836-466f08f62ced', {'ident': result['queue_ident']})
        else:
            try:
                self.in_process_queues[result['queue_ident']] = True
                yield self._startQueue(result, std_callbacks)
            finally:
                del(self.in_process_queues[result['queue_ident']])
        
    @defer.inlineCallbacks
    def _startQueue(self, result, std_callbacks={}):
        
        runQueue = yield self.dbGet('system', result['queue_ident'])
        
        if result.has_key('inputs'):
            input_set = dict([(x, True) for x in result['inputs']])
        else:
            input_set = {}
            
        currtime = datetime.datetime.now()
        x_nextminute = currtime + datetime.timedelta(minutes=1)
        next_minute = datetime.datetime(x_nextminute.year, x_nextminute.month, x_nextminute.day, x_nextminute.hour, x_nextminute.minute)

        try:
            qjs = yield self.mir.get('system', runQueue.queuedjobs)
        except Exception, e:
            self.err_msgs.render_log_msg('f6df4220-be64-4d2c-aa2e-f36e154f65d3', {'queued_job_ident': runQueue.href})
            return

        for qj in qjs:
            self.err_msgs.render_log_msg('be6287b9-dbf7-4e06-9242-a5221189a8c1', {'queued_job_ident': qj.href})

            if not runQueue.event and self.active_qjs.has_key(qj.href):
                self.err_msgs.render_log_msg('040045cc-7f8b-4061-8121-a87c312b7bff', {'queued_job_ident': qj.href})
                continue

            try:
                tjob = yield self.dbGet(qj.updater or qj.creator, qj.job)
            except Exception, e:
                self.err_msgs.render_log_msg('5704f819-87b4-4fd6-a666-bc41415d15c9', {'queued_job_ident': qj.href})
                continue
        
            tk = timekeeper.TimeKeeper(runQueue.get_cron_string(), identifier=qj.href, notBefore=qj.not_before, deleteAfter=qj.delete_after)
            
            if qj.delete_after and qj.delete_after < currtime:
                self.err_msgs.render_log_msg('750b1d1a-4875-4f8d-8444-d3f41b49df03', {'queued_job_ident': qj.href})
                yield self.mir.delete(qj.updater or qj.creator, qj)
                continue
                
            if runQueue.event or tk.should_run_at(currtime):
                job_rec = { "input_set": input_set.copy(), "queue": runQueue, "queued_job": qj, "jobObj": tjob, "job_ident": tjob.ident, "user_name": qj.updater or qj.creator }
                self.err_msgs.render_log_msg('1088ceec-896c-4a8e-8c70-381ff04b6633', {'queued_job_ident': qj.href})

                # updating status for queued job
                yield self.mir.set_status(qj.updater or qj.creator, qj.href, False, state='queued')

                self.active_qjs[qj.href] = True

                rsObj = yield self.initiate(job_rec, std_callbacks)
                qj.resultset = rsObj
                qj.last_run = currtime
                
                if not runQueue.event:
                    qj.next_run = tk.next_run(currtime)
    
                    # We don't care if the users set a delete_after on the QJ.
                    # If the QJ is non-recurring, then we will override the 
                    # delete_after and set to currtime so that it'll get deleted
                    # as soon as the job finishes.
                    if not qj.recur:
                        self.err_msgs.render_log_msg('13c515ff-7401-4eb9-8b01-51559b9398db', {'queued_job_ident': qj.href, 'currtime': currtime})
                        # triggers QJ deletion in receiveJobResults method.
                        qj.delete_after = currtime
                
                self.err_msgs.render_log_msg('8e0abd33-900c-4b49-8ac2-55088151fb11', {'queued_job_ident': qj.href})
                
                try:
                    yield self.mir.update(qj.updater or qj.creator, qj)
                except Exception, e:
                    # couldn't update the current queued job.
                    pass

                # updating status for queued job
                yield self.mir.set_status(qj.updater or qj.creator, qj.href, False, state='running')
            else:
                self.err_msgs.render_log_msg('7b9bc8d4-6a86-46b3-876b-0a337f12974e', {'queued_job_ident': qj.href})



    
    def cancel(self, message):
        data = yaml.safe_load(message._message)
        
        command = data['command']
        if command == 'CancelCommand':
            ident = data['ident']
            user = data['user']
            
            # determine class, and dispatch appropriately.
            # if auditResult -> agent_dispatcher
            # if analysisResult -> analyzer_dispatcher
            # if resultset -> both?
            
            dList = []
            ident = identity.identity_from_string(ident)
            if ident.type == 'AuditResult' or ident.type == 'ResultSet':
                sName = config_data.getByPath('service_names', 'agent_dispatcher')
                qName = config_data.getByPath('agent_dispatcher', 'queues', 'postqueue')
                dList.append((sName,qName))
            
            if ident.type == 'AnalysisResult' or ident.type == 'ResultSet':
                sName = config_data.getByPath('service_names', 'analyzer_dispatcher')
                qName = config_data.getByPath('analyzer_dispatcher', 'queues', 'postqueue')
                dList.append((sName,qName))
            
            for sName,qName in dList:
                msg = { 'command': 'CancelCommand', 'ident':str(ident), 'user':user}
                sIdent = wtutil.makeIdentity(sName)
                qIdent = wtutil.makeQueueIdentity(sIdent, qName)
                self.mbus.sendMessagetoQueue(qIdent, yaml.safe_dump(msg))
                self.err_msgs.render_log_msg('f0f4ee71-49a1-4d83-81cb-248657441d9a', {'ident': ident, 'queue_ident': qIdent, 'user': user})
                
            if ident.type =='ResultSet':
                pass #TODO: abort any further chained scripts on this job.


    

    # Test created - mir.script_runner.test.test_script_runner.testInitiate
    #                mir.script_runner.test.test_script_runner_with_db.testInitiate()
    #
    # ScriptRunner.initiate: Misnamed method.  Grab the data we need from the DB
    # then kick off the script runner process
    @defer.inlineCallbacks
    def initiate(self, job_rec, std_callbacks={}):
        """Pull Job information from the database."""
        
        self.err_msgs.render_log_msg('bee5922d-6030-45fa-a5f2-e704241f467b', {'job_ident': job_rec["job_ident"], 'queued_job_ident': job_rec['queued_job'].href})
        
        # Set up the job execution record.
        job_rec["issues"] = []
        
        jobIdentity = job_rec["job_ident"]
        jobObj = yield self.dbGet(job_rec['user_name'], jobIdentity)
        
        if True:
            base_inputs = execution_node.parseJobInput(job_rec['jobObj'].input)
            
            # is container?  is resolvable?
            # input possibilities:
            # 1) particle that resolves to itself only - Host
            # 2) particle that resolves to something else - Label
            # 3) container that resolves - Label/resources/  or AuditResul/documents/
            # 4) virtualized query - hosts/all/?filter=name,startswith,Foo
            # 5) 2, 3, or 4 above that resolve to nothing
            # 6) URI that resolves to a 404 error - unknown resource
            for t_input in base_inputs:
                resolved_inputs = None
            
                if re.search(r'\?', t_input):
                    (input_ident, query_args) = t_input.split('?')
                    input_ident = identity.identity_from_string(input_ident)
                    query_args = map(lambda x: x[7:].split(',', 3), filter(lambda y: re.search(r'^filter=', y), query_args.split('&')))
                    
                    resolved_inputs = yield self.mir.resolve_query(job_rec['user_name'], input_ident, query_args)

                else:
                    try:
                        input_ident = identity.identity_from_string(t_input)
                    except Exception, e:
                        # Bad input URI provided.  Skip it.  Move on.
                        job_rec['issues'].append(isu.Issue('Warning', 'Input Resolution', 'Invalid URI provided as input to Job.', t_input))
                        continue
                    
                    query_args = None
                    
                    mdl_type = getattr(models, input_ident.type, None)
                    
                    if mdl_type:
                        if input_ident._type == "particle":
                            if getattr(mdl_type, 'resolve_method', 'resolve_identity') != 'resolve_identity' :
                                try:
                                    input_obj = yield self.dbGet(job_rec['user_name'], input_ident)
                                    resolved_inputs = yield self.mir.resolve(job_rec['user_name'], input_obj)
                                except Exception, e:
                                    resolved_inputs = []
                            else:
                                resolved_inputs = [t_input]
                        elif input_ident._type == "container":
                            try:
                                t_objs = yield self.dbGet(job_rec['user_name'], input_ident)
                            except Exception, e:
                                t_objs = []
                                
                            resolved_inputs = map(lambda xx: xx.href, t_objs)
                
                if resolved_inputs: job_rec["input_set"].update(dict([(x, True) for x in resolved_inputs]))
            
        else:
            job_rec['input'] = job_rec['jobObj'].input
            job_rec["input_set"].update(dict([(x, True) for x in execution_node.parseJobInput(job_rec['input'])]))
        
        # create result set
        rsName="Results for %s at %s" % (job_rec['jobObj'].name, mir_datetime.strISO_now())
        rsObj = self.mir.ResultSet( name=rsName, 
                                    workspace_id=job_rec['job_ident'].workspace,
                                    state="pendingXXX",
                                    job=job_rec['jobObj'],
                                    schedule_summary=job_rec['queue'].get_cron_string(),
                                    run_time=mir_datetime.strISO_now(),
                                    input_count=len(job_rec["input_set"]),
                                    queued_job_ident=str(job_rec['queued_job'].ident))
        
        rsObj = yield self.mir.create(job_rec['user_name'], rsObj, where=identity.identity_from_string('%sresultsets/' % job_rec['jobObj'].ident))
        self.err_msgs.render_log_msg('c175ca2a-dd0c-4c22-8543-addf466fa771', {'resultset_ident': rsObj.ident, 'job_ident': jobIdentity})
        
        yield self.set_state(rsObj.ident, 'queued', job_rec['user_name'])

        # cache info for later use
        job_rec['result_ident'] = rsObj.ident
        job_rec['script'] = job_rec['jobObj'].script
        
        job_rec['job_elem_xml'] = dump_job_manifest(job_rec['jobObj'], job_rec['queue'])
        
        # The std_callbacks stuff is to allow me to halt the execution at this
        # or some future step in the path.  The two most basic situations are
        # std_callbacks is empty which results in all calls being made.  The other
        # main situation is where this function is given a False which will stop
        # processing here and not go to the next step.
        if not self.testing and (not std_callbacks.has_key("initiate") or std_callbacks["initiate"] == True):
            yield self.build_execution_tree(job_rec, std_callbacks)
    
        defer.returnValue(rsObj)
    

    

    # Test created - mir.script_runner.test.test_script_runner.testBuild_execution_tree()
    #                mir.script_runner.test.test_script_runner_with_db.testBuild_execution_tree()
    #
    # ScriptRunner.build_execution_tree
    # Take the job script and build an execution tree from it.  Parse the inputs contained
    # in the job record into a list of inputs.
    @defer.inlineCallbacks
    def build_execution_tree(self, job_rec, std_callbacks={}):
        """Building the execution tree for the job."""
        
        script_dom = minidom.parseString(job_rec['script'].encode('utf-8'))
        
        job_rec['base_execution_node'] = execution_node.processScript(script_dom.childNodes[0], config_data, workspace_id=job_rec['result_ident'].workspace, mbus=self.mbus, mir=self.mir, resultset=job_rec['result_ident'], user_name=job_rec['user_name'])
        
        if not std_callbacks.has_key("build_execution_tree") or std_callbacks["build_execution_tree"] == True:
            yield self.kickOffExecution(job_rec, self.receiveJobResults, std_callbacks)


        

    # Test created - mir.script_runner.test.test_script_runner.testKickOffExecution()
    #                mir.script_runner.test.test_script_runner_with_db.testKickOffExecution()
    #
    # ScriptRunner.kickOffExecution
    # Feed the input set to the base execution node of the execution tree.  This, in effect,
    # kicks off the job.  Also register to have the output of the job sent back to us so
    # that we can write it into the DB later.
    @defer.inlineCallbacks
    def kickOffExecution(self, job_rec, callback_func, std_callbacks={}):
        """Starts Execution of the job."""
        
        fh = self._writeInputs(job_rec["input_set"])
        if fh:
            job_rec['resolved_fh'] = fh
            log.msg("Resolved inputs for result set '%s' in '%s'." % (job_rec['result_ident'], fh.name))
        
        # update status
        rsObj = yield self.dbGet(job_rec['user_name'], job_rec['result_ident'])

        rsObj.state = "runningXXX"
        rsObj = yield self.mir.update(job_rec['user_name'], rsObj)
        
        yield self.set_state(rsObj.ident, 'running', job_rec['user_name'])
        
        # setup global job status
        numInputs = len(job_rec["input_set"])
        yield self.mir.set_status(job_rec['user_name'], job_rec['result_ident'], False, inputs_pending=numInputs, inputs_processed=0)
        
        # create manifest and update result set
        manifest_dom = yield self.createManifest(job_rec)
        filename = "Manifest for %s" % rsObj.name
        doc_id = yield self.createDocAndContent(job_rec=job_rec, filename=filename, content=manifest_dom.toxml('utf-8'))
        rsObj.manifest = doc_id
        rsObj = yield self.mir.update(job_rec['user_name'], rsObj)
        
        # If we don't have an InputSetListeners or InputItemListeners for
        # this base_execution_node, then we don't have anything to do.  So
        # we'll just set the node up to report as complete immediately.
        if len(job_rec['base_execution_node'].inputSetListeners) == 0 and len(job_rec['base_execution_node'].inputItemListeners) == 0:
            job_rec['base_execution_node'].allOutputsSent = True

        # If we don't have anything in our input_set, then we don't have 
        # anything to do.  So we'll just set the node up to report as complete 
        # immediately.
        if len(job_rec['input_set']) == 0:
            job_rec['base_execution_node'].allOutputsSent = True
            job_rec['base_execution_node'].outputMap = {}
            yield self.receiveJobResults({}, job_rec['base_execution_node'], job_rec)
        else:
            job_rec['base_execution_node'].outputSetListeners[str(job_rec['job_ident'])] = lambda x, y: callback_func(x, y, job_rec)
            job_rec['base_execution_node'].receiveInputSet(job_rec["input_set"].keys())
            
            self.active_jobs.append(job_rec)
        
        if not self.statsTimer:
            self.statsTimer = reactor.callLater(self.stats_timeout, self._logStats)

    
    # Test created - mir.agent_controller.test.test_agent_controller.testBuild_execution_tree
    #
    #
    # ScriptRunner.receiveJobResults
    # Receives the outputSet of the base execution node.  Takes the outputSet and correlates
    # to the inputs.  Adds any Analysis or AuditResults to the job's result set.  Finalizes
    # the manifest.
    @defer.inlineCallbacks
    def receiveJobResults(self, outputSet, sourceNode, job_rec, std_callbacks={}):
        """Processes the results of the job."""
        
        try:
            fh = job_rec.pop('resolved_fh',None)
            if fh:
                fh.close()
            self.active_jobs.remove(job_rec)
        except:
            pass
        
        issues_doc_id = None
        issuesList = sourceNode.gatherIssues()
        issuesList.extend(job_rec['issues'])
        
        if issuesList:
            xml = isu.generateIssuesXML(issuesList, 'ScriptRunner', '1.0')
            issues_doc_id = yield self.createDocAndContent(job_rec=job_rec, filename="issues.xml", content=xml, resultset=str(job_rec['result_ident']))
            
        rsObj = yield self.dbGet(job_rec['user_name'], job_rec['result_ident'])

        rsObj.state = "completeXXX"
        
        if issues_doc_id:
            rsObj.issues = issues_doc_id
            
        rsObj = yield self.mir.update(job_rec['user_name'], rsObj)
        
        yield self.set_state(rsObj.ident, 'acquired', job_rec['user_name'])

        # Finish the manifest
        maniObj = yield self.dbGet(job_rec['user_name'], rsObj.manifest)
        manifest_dom = yield self.createManifest(job_rec, sourceNode)
        
        fh = yield self.filep.open(maniObj.content_url, 'rw')
        fh.truncate()
        fh.write(manifest_dom.toxml('utf-8'))
        fh.close()
        
        if self.active_qjs.has_key(job_rec['queued_job'].href):
            del self.active_qjs[job_rec['queued_job'].href]
        
        # update status on queued job
        yield self.mir.set_status(job_rec['user_name'], job_rec['queued_job'].href, False, state='acquired')
        
        # Do I delete this queued job now?
        currtime = datetime.datetime.now()
        
        if job_rec.has_key('queued_job') and job_rec['queued_job'] and job_rec['queued_job'].href:
            t_qj = yield self.dbGet(job_rec['user_name'], job_rec['queued_job'].href)
        else:
            t_qj = None
        
        if t_qj:
            try:
                # delete_after set up in the runQueue method.
                if job_rec['queued_job'].delete_after and job_rec['queued_job'].delete_after < currtime:
                    log.msg('Deleting queuedjob %s because its delete_after is before now.' % job_rec['queued_job'].href, level='info')
                    yield self.mir.delete(job_rec['user_name'], job_rec['queued_job'])
                    del job_rec['queued_job']
            except Exception, e:
                # the queued job was there when checked, but something is wrong
                # now.
                pass
                
        yield self.mir.index_content('system', maniObj)
        

    
    
    # Test created - mir.agent_controller.test.test_agent_controller.testBuild_execution_tree
    #
    #
    # ScriptRunner.createManifest
    # Takes everything we know about the job and its execution and its results and builds
    # the manifest document for it.
    @defer.inlineCallbacks
    def createManifest(self, job_rec, sourceNode=None):
        """Processes the results of the job."""
    
        impl = minidom.getDOMImplementation()
        
        newdoc = impl.createDocument(None, "ManifestDocument", None)
        
        rsObj = yield self.dbGet(job_rec['user_name'], job_rec['result_ident'])
        
        job_elem = minidom.parseString(job_rec['job_elem_xml'])
        executionMetaData = minidom.parseString(dump_execution_manifest(rsObj))
        
        resultMap = newdoc.createElement('JobResults')
        if sourceNode:
            for outp, inp in sourceNode.traceOutput().iteritems():
                mapnode = newdoc.createElement("MapNode")
                inputnode = newdoc.createElement("Input")
                outputnode = newdoc.createElement("Output")
                inputnode_text = newdoc.createTextNode(inp)
                inputnode.appendChild(inputnode_text)
                outputnode_text = newdoc.createTextNode(outp)
                outputnode.appendChild(outputnode_text)
                mapnode.appendChild(inputnode)
                mapnode.appendChild(outputnode)
                resultMap.appendChild(mapnode)
        else:
            pass
        
        resolvedInputs = newdoc.createElement('ResolvedInputs')
        for t_input in job_rec["input_set"].keys():
            t_node = newdoc.createElement("input")
            t_node_text = newdoc.createTextNode(t_input)
            t_node.appendChild(t_node_text)
            resolvedInputs.appendChild(t_node)
            
        newdoc.childNodes[0].appendChild(job_elem.getElementsByTagName('JobDefinition')[0])
        newdoc.childNodes[0].appendChild(resultMap)
        md = executionMetaData.getElementsByTagName('JobExecutionMetaData')
        if md:
            newdoc.childNodes[0].appendChild(md[0])
        newdoc.childNodes[0].appendChild(resolvedInputs)
        
        defer.returnValue(newdoc)
        

    
    
    # Test created - mir.agent_controller.test.test_agent_controller.testCreateDocAndContent
    #
    # AgentController.createDocAndContent
    # Purpose in life:  Create a Document Resource and persist that resource.  Using the 
    # model for the Document resource, persist the content of that resource.  Ensure that
    # the resource and the content are indexed and ready to go.
    @defer.inlineCallbacks
    def createDocAndContent(self, job_rec=None, filename="somename", content="", resultset=None):
        """ Single operation to create a new Document resource and upload the content. """
        
        # use file provider to create fileuri
        fp = yield self.filep.create(job_rec["job_ident"].workspace, filename)
        fp.write(content)
        docUri = fp.uri
        mime, content_type = fp.detect_mime_types()
        fp.close()
        
        docObj = self.mir.Document(name = filename, workspace_id = job_rec["job_ident"].workspace)
        if resultset:
            docObj.resultset = resultset
        docObj.set_content(docUri, content_type)
        
        # create
        docObj = yield self.mir.create(job_rec['user_name'], docObj)
        
        # index
        yield self.mir.index_content('system', docObj)
        
        # return uri
        defer.returnValue(docObj.ident)
        

    
    
    @defer.inlineCallbacks
    def dbGet(self, user, uri):
        """ retrieve specified object from database """
        try:
            outObj = yield self.mir.get(user, uri)
            if not outObj:
                raise ValueError("Object '%s' not in database." % uri)
        except Exception, e:    
            self.err_msgs.render_log_msg('94f8cdb0-d3a0-4c7a-a8b6-03c99246706a', {'resource_ident': uri, 'error_message': unicode(e)})
            raise
            
        defer.returnValue(outObj)
    
    
        

    @defer.inlineCallbacks
    def set_state(self, ident, state, user='system'):
        try:
            yield self.mir.set_status(user, ident, True, state=state)
            self.err_msgs.render_log_msg('50c74768-2159-4bc5-85a2-3316eed8a507', {'ident': ident, 'state': state})
        except Exception, e:
            self.err_msgs.render_log_msg('cc8e269a-7e19-4806-848f-32abd884b06e', {'ident': ident, 'error_message': unicode(e)})
            

    def _logStats(self):
        try:
            for job_rec in self.active_jobs:
                bn = job_rec['base_execution_node']
                i = 0
                for node in bn.gatherSubNodes():
                    numInputs = len(node.inputMap)
                    numOutputs = 0
                    for v in node.inputMap.itervalues():
                        if v != None:
                            numOutputs += 1
                            
                    log.msg("stats ResultSet: %s Cmd#:%i Inputs:%i Outputs:%i" % (job_rec['result_ident'], i, numInputs, numOutputs))
                    i += 1
        except Exception,e:
            log.msg("Unexpected exception logging stats: '%s'" % e)
            
        if self.active_jobs:
            self.statsTimer = reactor.callLater(self.stats_timeout, self._logStats)
        else:
            self.statsTimer = None
            
    def _writeInputs(self, inputs):
        """ Write list of inputs to temporary .xml file for diagnostics.
            Requested by support team.
        """
        try:
            
            dList = ["""<?xml version="1.0" encoding="utf-8"?>\n\n"""]
            dList.append("<inputs>\n")
            for input in inputs.keys():
                dList.append("  <input>%s</input>\n" % str(input))
            dList.append("</inputs>\n\n")
            data = ''.join(dList)
            fh = tempfile.NamedTemporaryFile(prefix="scriptrunner_", suffix=".xml")
            fh.write(data.encode("utf-8"))
            fh.flush()
        except:
            fh = None
        return fh
        

def dump_execution_manifest(rsObj):
    xml = '<?xml version="1.0" encoding="utf-8"?>'
    xml += '<JobExecutionMetaData xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
    xml += '<creator username="%s"/>'   % rsObj.creator
    xml += '<created>%s</created>'      % rsObj.created
    xml += '<updater username="%s" />'  % rsObj.updater
    xml += '<updated>%s</updated>'      % rsObj.updated
    xml += '</JobExecutionMetaData>'
    return xml.encode("utf-8")
            
def dump_job_manifest(jobObj, queueObj):
    xml = '<?xml version="1.0" encoding="utf-8"?>'
    xml += '<JobDefinition xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" href="%s">'  % jobObj.href
    xml += '%s\n'               % re.sub(r'^<\?[^\?]+\?>', '', jobObj.script)
    xml += '<when>%s</when>\n'  % re.sub(r'^<\?[^\?]+\?>', '', queueObj.get_cron_string())
    xml += '%s\n'               % re.sub(r'^<\?[^\?]+\?>', '', jobObj.input)
    xml += '</JobDefinition>'
    return xml.encode("utf-8")
    
    
        
