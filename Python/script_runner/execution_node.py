import re as re
import yaml
import time
import xml.dom.minidom as minidom

import twisted.python.log as log
import twisted.internet.defer as defer
import mandiant.utils.uuid as uuid
import mandiant.utils.call_trace as call_trace
import mandiant.windtalker.util as util

import mir.models.models as models
import mir.config as config
import mir.log_service.log_service as log_service
import mir.script_runner.execution_node_base as enb


# load the config for this service
config_data = config.MirConfig("scriptrunner")
config_data.loadServiceConfig('agent_dispatcher')
config_data.loadServiceConfig('fileserver')
config_data.loadServiceConfig('search')
config_data.loadServiceConfig('analyzer_dispatcher')
config_data.loadServiceConfig('scheduler')
config_data.loadServiceConfig('log_service')
do_tracing = config_data.getByPath("script_runner", "tracing_level")


class ExecutionNode(enb.ExecutionNode_Base):
    agentcontroller_ident = util.makeIdentity(config_data.getByPath('service_names', 'agent_dispatcher'))
    analyzer_ident = util.makeIdentity(config_data.getByPath('service_names', 'analyzer_dispatcher'))
    scriptrunner_ident = util.makeIdentity(config_data.getByPath('service_names', 'script_runner'))
    logservice_ident = util.makeIdentity(config_data.getByPath('service_names', 'log_service'))

    def __init__(self, config_data, top_level=False, user_name='system', workspace_id=1, configs={}, status_interval=None, testing=False, resultset=None, transfermode='batch', resolveInputSets=False, db=None, command="", name=None, handler=None, params="", script="", chaining=None, nodelist=None, mbus=None, mir=None, debug_level=0):
        enb.ExecutionNode_Base.__init__(self, testing=testing, command=command, resolveInputSets=resolveInputSets, name=name, params=params, script=script, transfermode=transfermode, chaining=chaining, nodelist=nodelist, debug_level=debug_level)

        self.user_name = user_name
        self.mbus = mbus
        self.mir = mir
        self.db = db
        self.handler = handler
        self.config_data = config_data
        self.resultItemQueue = None
        self.resultSetQueue = None
        self.workspace_id = workspace_id
        self.resultset = resultset
        self.configs = configs
        self.max_concurrent_agent_sessions = self.config_data.getByPath('script_runner', 'max_concurrent_agent_sessions')

        self.commandStatus = False
        self.commandStatusTimestamp = False
        
        self.issues = []
        
        if self.resultset is not None:
            self.resultset_href = str(self.resultset)
        else:
            self.resultset_href = ""

        if self.mbus:
            self.resultItemQueue = "%s%s/item/" % (self.config_data.getByPath('script_runner', 'queues', 'jobqueuebase'), self.id)
            self.resultSetQueue = "%s%s/set/" % (self.config_data.getByPath('script_runner', 'queues', 'jobqueuebase'), self.id)

            self.mbus.add_queue(self.resultItemQueue, self.receiveResultItem)
            self.mbus.add_queue(self.resultSetQueue, self.receiveResultSet)

            log.msg("user_name: %s" % (self.user_name), level="info")
            
            self.command_mesg = {'resultset': self.resultset_href.encode(), 
                                 'max_concurrent_agent_sessions': self.max_concurrent_agent_sessions, 
                                 'command': self.command.encode('utf-8'), 
                                 'params': self.params.encode('utf-8'), 
                                 'script': self.script.encode('utf-8'), 
                                 'results_queue': util.makeQueueIdentity(self.scriptrunner_ident, self.resultSetQueue), 
                                 'user': self.user_name,
                                }
            
    
    def receiveResultItem(self, message):
        body = yaml.safe_load(message._message)
        
        issues = body.get('issues')
        if issues:
            self.issues.extend(issues)
        
        result = body['results']
        
        log.msg("Command %s Received result item: %s" % (self.command, result))

        super(ExecutionNode, self).receiveResultItem(result)
        
        self.updateGlobalStatus()

        #yield self.mir.set_status('system', result['input_uri'], 'f', sr_resultset=self.resultset.__str__(), sr_stage='received')

            
    def receiveResultSet(self, message):
        body = yaml.safe_load(message._message)
        
        issues = body.get('issues')
        if issues:
            self.issues.extend(issues)
        
        result = body['results']
        
        log.msg("Command %s Received result set: %s" % (self.command, result))
        
        super(ExecutionNode, self).receiveResultSet(result)
        
        self.updateGlobalStatus()
        
        #for xxtup in result:
        #    yield self.mir.set_status('system', xxtup['input_uri'], 'f', sr_resultset=self.resultset.__str__(), sr_stage='received')

    def updateGlobalStatus(self):
        try:
            # base node sets global status
            if not self.parents:
                total = len(self.inputMap)
                done = len(filter(lambda x: self.inputMap[x], self.inputMap.keys()))
                self.mir.set_status(self.user_name, self.resultset_href, False, inputs_pending=total-done, inputs_processed=done)
                
        except Exception, e:
            log.msg("Non-critical error '%s' setting global status in execution_node." % e, level='minor')
            
        
    def gatherIssues(self):
        issues = []
        """ walk tree depth first and gather issues """
        nodes = self.gatherSubNodes()
        for node in nodes:
            issues.extend(node.gatherIssues())
        issues.extend(self.issues)
        return issues
    

    @defer.inlineCallbacks
    def _receiveInputItem(self, inputItem, sourceNode):
        super(ExecutionNode, self)._receiveInputItem(inputItem, sourceNode)
        
        if self.handler:
            self.command_mesg['inputs'] = [ inputItem ]
            self.command_mesg['results_queue'] = util.makeQueueIdentity(self.scriptrunner_ident, self.resultItemQueue)
            self.command_mesg['user'] = self.user_name
            self.command_mesg['inputDone'] = self.allInputsReceived
            
            if self.handler == 'AgentController':
                queue_name = self.config_data.getByPath('agent_dispatcher', 'queues', 'postqueue')
                fqqn = util.makeQueueIdentity(self.agentcontroller_ident, queue_name)
            else:
                queue_name = self.config_data.getByPath('analyzer_dispatcher', 'queues', 'postqueue')
                fqqn = util.makeQueueIdentity(self.analyzer_ident, queue_name)
                
            log.msg("Command %s sent an input item to queue: %s" % (self.command, queue_name))
            log.msg("Command mesg: %s" % yaml.safe_dump(self.command_mesg))
            
            yield self.mbus.sendMessagetoQueue(fqqn, yaml.safe_dump(self.command_mesg))
            #yield self.mir.set_status('system', inputItem, 'f', sr_resultset=self.resultset.__str__(), sr_stage='dispatched')
        
    @defer.inlineCallbacks
    def receiveInputSet(self, inputSet, sourceNode=None):
        super(ExecutionNode, self).receiveInputSet(inputSet, sourceNode)

        if self.handler:
            self.command_mesg['inputs'] = filter(lambda x: x != None, self.inputSet)
            self.command_mesg['results_queue'] = util.makeQueueIdentity(self.scriptrunner_ident, self.resultItemQueue)
            self.command_mesg['user'] = self.user_name
            self.command_mesg['inputDone'] = True
            self.command_mesg['issues'] = self.issues
            
            if self.handler == 'AgentController':
                queue_name = self.config_data.getByPath('agent_dispatcher', 'queues', 'postqueue')
                fqqn = util.makeQueueIdentity(self.agentcontroller_ident, queue_name)
            else:
                queue_name = self.config_data.getByPath('analyzer_dispatcher', 'queues', 'postqueue')
                fqqn = util.makeQueueIdentity(self.analyzer_ident, queue_name)
                
            log.msg("Command %s sent an input set to queue: %s" % (self.command, fqqn))
            yield self.mbus.sendMessagetoQueue(fqqn, yaml.safe_dump(self.command_mesg))
            
            #for xx in self.command_mesg['inputs']:
            #    yield self.mir.set_status('system', xx, 'f', sr_resultset=self.resultset.__str__(), sr_stage='dispatched')

        

def processCommand(config_data, user_name='system', workspace_id=1, mbus=None, mir=None, resultset=None, statusRoot=None):
    def en_processCommand(commandElem, super=None, parent=None, nodelist=None, numsibs=0):
        if commandElem.hasAttribute('xsi:type'):
            command = commandElem.getAttribute('xsi:type')
        elif commandElem.hasAttribute('ns0:type'):
            command = commandElem.getAttribute('ns0:type')
        else:
            return None
            
        if commandElem.hasAttribute('transfermode'):
            transfermode = commandElem.getAttribute('transfermode')
        else:
            transfermode = 'batch'
            
        params = []
        script = None
        name = commandElem.attributes.get('id').value
        handler = "AnalyzerController"
        
        if command == 'AuditHostScriptCommand':
            commandElem.getElementsByTagName('script')[0].setAttribute('xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance')
            commandElem.getElementsByTagName('script')[0].setAttribute('xmlns:xsd','http://www.w3.org/2001/XMLSchema')
            script = commandElem.getElementsByTagName('script')[0].toxml()
            handler = "AgentController"
        else:
            pass
    
        inputElem = None
        outputElem = None
        
        for param in enb.getInterestingChildren(commandElem):
            if param.tagName == 'script': continue
            if param.tagName == 'input': inputElem = param
            if param.tagName == 'result': outputElem = param
            
            params.append(param.toxml())
            
        commandNode = ExecutionNode(config_data=config_data, user_name=user_name, transfermode=transfermode, resultset=resultset, workspace_id=workspace_id, script=script, handler=handler, command=command, params="<params>%s</params>" % '\n'.join(params), nodelist=nodelist, name=name, mbus=mbus, mir=mir)

        #commandNode.statusNode = status.StatusNode(statusRoot, int(100/numsibs)) 
        
        return enb._structural_processCommand(commandElem=commandElem, commandNode=commandNode, super=super, parent=parent, inputElem=inputElem, outputElem=outputElem)

    return en_processCommand
        
        
def processScript(scriptElem, config_data, user_name='system', workspace_id=1, mbus=None, mir=None, resultset=None, top_level=True):
    # process a script element meaning create an Execution Node and
    # connect sub/supers, parent/children, and inputs and outputs to
    # their correct places based on chaining strategy and script state.
    
    en_processCommand = processCommand(config_data, user_name=user_name, workspace_id=workspace_id, mbus=mbus, mir=mir, resultset=resultset)
    
    def en_processScript(scriptElem, super=None, parent=None, nodelist=None, script_cb=None, command_cb=None, statusNode=None, numsibs=0, top_level=False):
        params = None
        command = 'Script'
        chaining = scriptElem.attributes.get('chaining').value
        name = scriptElem.attributes.get('id').value
        
        scriptNode = ExecutionNode(top_level=top_level, config_data=config_data, user_name=user_name, workspace_id=workspace_id, resultset=resultset, chaining=chaining, command=command, params=params, nodelist=nodelist, name=name, mbus=mbus, mir=mir)
    
        #scriptNode.statusNode = statusNode
        ## FIXME: Ignoring sub scripts at this point.  Will fix when we migrate all status
        ## to status service.
        
        inputElem = None
        outputElem = None
        
        return enb._structural_processScript(scriptElem=scriptElem, scriptNode=scriptNode, super=super, parent=parent, nodelist=nodelist, inputElem=inputElem, outputElem=outputElem, script_cb=script_cb, command_cb=command_cb)


    base_node = en_processScript(scriptElem, super=None, parent=None, nodelist=None, script_cb=en_processScript, command_cb=en_processCommand, top_level=top_level)
    return base_node


def parseURIList(inputString):
    inputDom = minidom.parseString("<input>%s</input>" % inputString)
    inputSet = []
    
    for uri in inputDom.getElementsByTagName('uri'):
        inputSet.append(uri.childNodes[0].nodeValue.encode())
        
    return inputSet

    
def parseJobInput(inputString):
    if re.search(r'<uri>', inputString):
        return parseURIList(inputString)

    return []


    
