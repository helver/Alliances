import re as re

import twisted.python.log as log
import mandiant.utils.uuid as uuid
import mir.error_messages as mir_err


MND_error_message_code = 'SCR'
MND_error_messages = {
}
[MND_error_messages[x_err_msg].update({'code': MND_error_message_code}) for x_err_msg in MND_error_messages]


class ExecutionNode_Base(object):
    def __init__(self, testing=False, resolveInputSets=False, name=None, command=None, params="", script="", chaining=None, transfermode='batch', nodelist=None, debug_level=0):
        if params == None:
            self.params = ''
        else:
            self.params = params
            
        if script == None:
            self.script = ''
        else:
            self.script = script
            
        if command == None:
            self.command = ''
        else:
            self.command = command
            
        self.chaining = chaining
        self.transfermode = transfermode
        self.children = []
        self.parents = []
        self.subcommands = []
        self.supercommands = []
        self.id = str(uuid.uuid4())
        self.name = name
        self.resolveInputSets = resolveInputSets
        self.testing = testing
        self.debug_level = debug_level
        
        self.inputItemListeners = {}
        self.outputItemListeners = {}
        self.inputSetListeners = {}
        self.outputSetListeners = {}

        self.inputMap = {}
        self.inputSet = []
        self.allInputsReceived = False
        self.allResultsReceived = False
        self.allOutputsSent = False
        
        self.delayedRegistrations = []
        
        if nodelist == None:
            self.allnodes = {}
        else:
            self.allnodes = nodelist
            
        self.allnodes[self.id] = self
        self.err_msgs = mir_err.MIR_Error_Messages(MND_error_message_code, log.msg)
        
    
    def dumpNodeGraph(self=None):
        for node in self.allnodes.values():
            print "\n%s(%s):\n   parents(%s),\n   children(%s),\n   supers(%s),\n   subs(%s),\n   inputItemListeners(%s),\n   outputItemListeners(%s),\n   inputSetListeners(%s),\n   outputSetListeners(%s)\n" % (node.name, node.id, ','.join(map(lambda x: node.getNameByNodeID(x), node.parents)), ','.join(map(lambda x: node.getNameByNodeID(x), node.children)), ','.join(map(lambda x: node.getNameByNodeID(x), node.supercommands)), ','.join(map(lambda x: node.getNameByNodeID(x), node.subcommands)), ','.join(map(lambda x: node.getNameByNodeID(x), node.inputItemListeners.keys())), ','.join(map(lambda x: node.getNameByNodeID(x), node.outputItemListeners.keys())), ','.join(map(lambda x: node.getNameByNodeID(x), node.inputSetListeners.keys())), ','.join(map(lambda x: node.getNameByNodeID(x), node.outputSetListeners.keys())))
        

    def receiveResultItem(self, result):
        if type(result) == list:
            log.msg("But it's really a list of items.")
            for i in result:
                self._receiveResultItem(i)
        else:
            self._receiveResultItem(result)
            

    def _receiveResultItem(self, result):
        self.inputMap[result['input_uri']] = result['output_uri']
        self.receiveOutputItem(result['output_uri'], sourceNode=self, viaResult=True)
        
    
    def receiveResultSet(self, result):
        if type(result) != list:
            log.msg("But it wasn't actually a list.")
            result = [result]
            
        self.outputSet = []
        for xxtup in result:
            self.inputMap[xxtup['input_uri']] = xxtup['output_uri']
            self.outputSet.append(xxtup['output_uri'])
            
        self.receiveOutputSet(sourceNode=self, viaResult=True)
        
        
    def gatherSubNodes(self):
        nodes = [self.getNodeByNodeID(id) for id in (self.children + self.subcommands)]
        return nodes
    
    
    def checkIfAllResultsReceived(self):
        if not self.allInputsReceived:
            log.msg("Command %s all results not received because all inputs not received." % self.command)
            return False
        
        for i in self.inputMap:
            if self.inputMap[i] == None:
                log.msg("Command %s all results not received because some inputs do not have outputs." % self.command)
                self.allResultsReceived = False
                return self.allResultsReceived
        
        log.msg("Command %s - all results received." % self.command)
        self.allResultsReceived = True
        
        for x_child in self.children:
            self.getNodeByNodeID(x_child).allInputsReceived = True
            
        return self.allResultsReceived

    
    def constructOutputSet(self):
        outputSet = []
        
        for i in self.inputSet:
            outputSet.append(self.inputMap[i])
            
        return outputSet

    
    def setParent(self, parentNode):
        self.parents.append(parentNode.id)
        parentNode.children.append(self.id)
        
    def setChild(self, childNode):
        self.children.append(childNode.id)
        childNode.parents.append(self.id)
        
    def setSubCommand(self, subNode):
        self.subcommands.append(subNode.id)
        subNode.supercommands.append(self.id)
        
    def setSuperCommand(self, superNode):
        self.supercommands.append(superNode.id)
        superNode.subcommands.append(self.id)

    def requestInputItem(self, inputNode, method):
        inputNode.inputItemListeners[self.id] = method
        
    def requestInputSet(self, inputNode, method):
        inputNode.inputSetListeners[self.id] = method
        
    def requestOutputItem(self, outputNode, method):
        outputNode.outputItemListeners[self.id] = method

    def requestOutputSet(self, outputNode, method):
        outputNode.outputSetListeners[self.id] = method

    def requestInputItemByName(self, inputNodeName, method):
        self.delayedRegistrations.append({'nodeName': inputNodeName, 'set': 'inputItemListeners', 'method': method})
        
    def requestInputSetByName(self, inputNodeName, method):
        self.delayedRegistrations.append({'nodeName': inputNodeName, 'set': 'inputSetListeners', 'method': method})
        
    def requestOutputItemByName(self, outputNodeName, method):
        self.delayedRegistrations.append({'nodeName': outputNodeName, 'set': 'outputItemListeners', 'method': method})

    def requestOutputSetByName(self, outputNodeName, method):
        self.delayedRegistrations.append({'nodeName': outputNodeName, 'set': 'outputSetListeners', 'method': method})

    def receiveInputItem(self, inputItem, sourceNode):
        log.msg("Command %s Received Input item from %s: %s" % (self.command, sourceNode.command, inputItem))

        if type(inputItem) == list:
            log.msg("But it was actually a list.")
            for i in inputItem:
                self._receiveInputItem(i, sourceNode=sourceNode)
            self.receiveInputSet([], sourceNode=sourceNode)
        else:
            self._receiveInputItem(inputItem, sourceNode=sourceNode)

            

    def _receiveInputItem(self, inputItem, sourceNode):
        for listener in self.inputItemListeners.keys():
            self.inputItemListeners[listener](inputItem, sourceNode=self)
            
        self.inputMap[inputItem] = None
        self.inputSet.append(inputItem)
        
        
    def senderDoneSending(self, sourceNode):
        if sourceNode in self.supercommands:
            # It's a wrapping Script elem.  It's done when it's sent us all its Inputs.
            
            return sourceNode.allInputsReceived
            
        elif sourceNode in self.parents:
            # It's a previous command in the chain.  It's done when it's sent us all 
            # its outputs.
            
            return sourceNode.allOutputsSent

        else:
            return True

    def receiveInputSet(self, inputSet, sourceNode=None):
        log.msg("Command %s Received Input set from %s: %s" % (self.command, (sourceNode and sourceNode.command or ""), inputSet))

        if type(inputSet) != list:
            inputSet = [inputSet]
            log.msg("But it was actually a string.")

        newInputs = {}
        _ = map(newInputs.setdefault, inputSet, [])
            
        self.inputMap.update(newInputs)
        if self.inputMap.has_key(None):
            del[self.inputMap[None]]
            
        if self.inputMap.has_key(''):
            del[self.inputMap['']]
            
        self.inputSet.extend(filter(lambda x: x != None and x != '', inputSet))
        
        if sourceNode and not self.senderDoneSending(sourceNode):
            log.msg("Command %s - received input set, but not all inputs received from %s." % (self.command, sourceNode.command))
            self.allInputsReceived = False
        else:
            log.msg("Command %s - received input set.  Invoking input set listeners." % self.command)
            self.allInputsReceived = True
            for listener in self.inputSetListeners:
                self.inputSetListeners[listener](self.inputSet, sourceNode=self)


    def receiveOutputItem(self, outputItem, sourceNode, viaResult=False):
        log.msg("Command %s Received Output item from %s: %s" % (self.command, sourceNode.command, outputItem))

        if type(outputItem) == list:
            log.msg("But it was actually a list.")
            for i in outputItem:
                self._receiveOutputItem(i, sourceNode, viaResult=viaResult)
        else:
            self._receiveOutputItem(outputItem, sourceNode, viaResult=viaResult)
            

    def _receiveOutputItem(self, outputItem, sourceNode, viaResult=False):
        if self.checkIfAllResultsReceived():
            self.receiveOutputSet(viaResult=viaResult, sourceNode=sourceNode)

        for listener in self.outputItemListeners.keys():
            self.outputItemListeners[listener](outputItem, sourceNode=self)
            


    def receiveOutputSet(self, outputSet=None, sourceNode=None, viaResult=False):
        log.msg("Command %s Received Output set from %s: %s" % (self.command, (sourceNode and sourceNode.command or ""), outputSet))
        if viaResult:
            if self.checkIfAllResultsReceived():
                self.outputSet = self.constructOutputSet()
                self.outputMap = dict([(v, k) for (k, v) in self.inputMap.iteritems()])
                self.allOutputsSent = True
                
                for listener in self.outputSetListeners.keys():
                    self.outputSetListeners[listener](self.outputSet, self)
        else:
            # Wrong.  Need to figure out if I've received all the
            # results I'm waiting for.  Don't just fire out an output
            # set because I've received one - think batch operations.
            inputProviders = filter(lambda x: self.id in x.outputSetListeners or self.id in x.outputItemListeners, self.allnodes.values())
            
            if inputProviders and len(inputProviders) >= 1:
                self.allOutputsSent = reduce(lambda x, y: x and y, map(lambda x: x.allOutputsSent, inputProviders))
            else:
                self.allOutputsSent = True
                
            if hasattr(self, 'outputSet'):
                self.outputSet.extend(outputSet)
            else:
                self.outputSet = outputSet[:]
            
            for listener in self.outputSetListeners.keys():
                self.outputSetListeners[listener](outputSet, self)
    
    def getCommandByNodeID(self, nodeID):
        return self.allnodes[nodeID].command
    
    def getNodeByNodeID(self, nodeID):
        return self.allnodes[nodeID]
    
    def getNameByNodeID(self, nodeID):
        return self.allnodes[nodeID].name
    
    def getNodeByName(self, name):
        for t_node in self.allnodes.values():
            if t_node.name == name: return t_node
            
        return None
    
    def getAllOutputListeners(self):
        outputListener = []
        outputListener.extend(self.outputSetListeners.keys())
        outputListener.extend(self.outputItemListeners.keys())
        return outputListener
    
    def getAllInputListeners(self):
        inputListener = []
        inputListener.extend(self.inputSetListeners.keys())
        inputListener.extend(self.inputItemListeners.keys())
        return inputListener
    
    def traceIOPaths(self, topNode=True):
        if len(self.subcommands) > 0:
            if not topNode:
                return self.getAllOutputListeners()[0]
                
            if self.chaining == "none":
                return [self.subcommands]
            
            iopath = []
            next_step = self.getAllInputListeners()[0]
            
            while next_step != self.id:
                iopath.append(next_step)
                next_step = self.getNodeByNodeID(next_step).traceIOPaths(topNode=False)
                
            return iopath
            
        else:
            return self.getAllOutputListeners()[0]
    
    def traceOutput(self):
        if hasattr(self, 'outputMap'):
            return self.outputMap
        
        iopath = self.traceIOPaths()
        
        if self.chaining == "none":
            self.outputMap = {}
            for x in iopath:
                self.outputMap.update(self.getNodeByNodeID(x).traceOutput())
        else:
            for xxx in reversed(iopath):
                if hasattr(self, 'outputMap'):
                    qq = self.getNodeByNodeID(xxx)
                    
                    #for (xx, yy) in self.outputMap.iteritems():
                    #    self.outputMap[xx] = qq.outputMap[yy]
                        
                    self.outputMap = dict((x, qq.outputMap[y]) for x, y in self.outputMap.iteritems())
                    
                    #map(lambda x: self.outputMap[x] = qq.outputMap[self.outputMap[x]], self.outputMap.keys())
                else:
                    self.outputMap = {}
                    self.outputMap.update(self.getNodeByNodeID(xxx).outputMap)
        
        return self.outputMap
        

    def resolveDelayedRegistrations(self):
        if len(self.delayedRegistrations) == 0: return
        
        tmp = self.delayedRegistrations[:]
        self.delayedRegistrations = []
        for dr in tmp:
            t_node = self.getNodeByName(dr["nodeName"])
            if t_node:
                f = getattr(t_node, dr['set'])
                f[self.id] = dr['method']
            else:
                self.delayedRegistrations.append(dr)
    

def getInterestingChildren(t_elem):
    result_set = []
    for child in t_elem.childNodes:
        if not hasattr(child, 'tagName') or child.tagName == None:
            continue
    
        result_set.append(child)
        
    return result_set


def processExplicitInput(t_elem, t_node):
    try:
        input_src_id = t_elem.getElementsByTagName('src_id')[0].childNodes[0].nodeValue
    except:
        input_src_id = None
    
    try:
        input_src_field = t_elem.getElementsByTagName('src_field')[0].childNodes[0].nodeValue
    except:
        input_src_field = "input"
    
    if input_src_id:
        if input_src_field == "input":
            if t_node.transfermode == 'stream':
                t_node.requestInputItemByName(input_src_id, t_node.receiveInputItem)
            else:
                t_node.requestInputSetByName(input_src_id, t_node.receiveInputSet)
        else:
            if t_node.transfermode == 'stream':
                t_node.requestOutputItemByName(input_src_id, t_node.receiveInputItem)
            else:
                t_node.requestOutputSetByName(input_src_id, t_node.receiveInputSet)


def processExplicitOutput(t_elem, t_node):
    try:
        output_src_id = t_elem.getElementsByTagName('src_id')[0].childNodes[0].nodeValue
    except:
        output_src_id = None
    
    try:
        output_src_field = t_elem.getElementsByTagName('src_field')[0].childNodes[0].nodeValue
    except:
        output_src_field = "result"
    
    if output_src_id:
        if output_src_field == "input":
            if t_node.transfermode == 'stream':
                t_node.requestInputItemByName(output_src_id, t_node.receiveOutputItem)
            else:
                t_node.requestInputSetByName(output_src_id, t_node.receiveOutputSet)
        else:
            if t_node.transfermode == 'stream':
                t_node.requestOutputItemByName(output_src_id, t_node.receiveOutputItem)
            else:
                t_node.requestOutputSetByName(output_src_id, t_node.receiveOutputSet)


def processCommand(commandElem, super=None, parent=None, nodelist=None, numsibs=0):
    name = str(uuid.uuid4())
    inputElem = None
    outputElem = None
    command = 'Base'
    
    commandNode = ExecutionNode_Base(command=command, nodelist=nodelist, name=name)

    return _structural_processCommand(commandElem=commandElem, commandNode=commandNode, super=super, parent=parent, inputElem=inputElem, outputElem=outputElem)
        
        
def _structural_processCommand(commandElem, commandNode, super=None, parent=None, inputElem=None, outputElem=None):
    if parent: commandNode.setParent(parent)
    if super: commandNode.setSuperCommand(super)

    if super and super.chaining == 'none':
        if commandNode.transfermode == 'stream':
            commandNode.requestInputItem(super, commandNode.receiveInputItem)
            super.requestOutputItem(commandNode, super.receiveOutputItem)
        else:
            commandNode.requestInputSet(super, commandNode.receiveInputSet)
            super.requestOutputSet(commandNode, super.receiveOutputSet)
            
    elif super and super.chaining == 'explicit':
        if inputElem: processExplicitInput(inputElem, commandNode)
        if outputElem: processExplicitOutput(outputElem, commandNode)
    else:
        if parent:
            if commandNode.transfermode == 'stream':
                commandNode.requestOutputItem(parent, commandNode.receiveInputItem)
            else: 
                commandNode.requestOutputSet(parent, commandNode.receiveInputSet)
        else:
            if commandNode.transfermode == 'stream':
                commandNode.requestInputItem(super, commandNode.receiveInputItem)
            else:
                commandNode.requestInputSet(super, commandNode.receiveInputSet)
    
    return commandNode
        


def processScript(scriptElem, super=None, parent=None, nodelist=None, numsibs=0):
    # process a script element meaning create an Execution Node and
    # connect sub/supers, parent/children, and inputs and outputs to
    # their correct places based on chaining strategy and script state.
    
    command = 'Script'
    chaining = 'none'
    name = str(uuid.uuid4())
    
    scriptNode = ExecutionNode_Base(chaining=chaining, command=command, nodelist=nodelist, name=name)

    inputElem = None
    outputElem = None
    
    return enb._structural_processScript(scriptElem=scriptElem, scriptNode=scriptNode, super=super, parent=parent, nodelist=nodelist, inputElem=inputElem, outputElem=outputElem, script_cb=processScript, command_cb=processCommand)


def _structural_processScript(scriptElem, scriptNode, super=None, parent=None, nodelist=None, inputElem=None, outputElem=None, script_cb=None, command_cb=None):
    for scriptChild in getInterestingChildren(scriptElem):
        if scriptChild.tagName == 'commands':
            local_parent = None
            numchildren = len(getInterestingChildren(scriptChild))
            for commandChild in getInterestingChildren(scriptChild):
                if commandChild.tagName == 'command':
                    node = command_cb(commandChild, super=scriptNode, parent=local_parent, nodelist=scriptNode.allnodes, numsibs=numchildren)
                if commandChild.tagName == 'script':
                    node = script_cb(commandChild, super=scriptNode, parent=local_parent, nodelist=scriptNode.allnodes, script_cb=script_cb, command_cb=command_cb, numsibs=numchildren)
                local_parent = node
        elif scriptChild.tagName == 'input':
            inputElem = scriptChild
        elif scriptChild.tagName == 'result':
            outputElem = scriptChild
            

    if parent: scriptNode.setParent(parent)
    if super: scriptNode.setSuperCommand(super)

    if parent or super:
        if super and super.chaining == 'none':
            if scriptNode.transfermode == 'stream':
                scriptNode.requestInputItem(super, scriptNode.receiveInputItem)
                super.requestOutputItem(scriptNode, super.receiveOutputItem)
            else:
                scriptNode.requestInputSet(super, scriptNode.receiveInputSet)
                super.requestOutputSet(scriptNode, super.receiveOutputSet)
                
        elif super and super.chaining == 'explicit':
            if inputElem: processExplicitInput(inputElem, scriptNode)
            if outputElem: processExplicitOutput(outputElem, scriptNode)

        else:
            if parent: 
                if scriptNode.transfermode == 'stream':
                    scriptNode.requestOutputItem(parent, scriptNode.receiveInputItem)
                else:
                    scriptNode.requestOutputSet(parent, scriptNode.receiveInputSet)
            else:
                if scriptNode.transfermode == 'stream':
                    scriptNode.requestInputItem(super, scriptNode.receiveInputItem)
                else:
                    scriptNode.requestInputSet(super, scriptNode.receiveInputSet)
            if local_parent: 
                if scriptNode.transfermode == 'stream':
                    scriptNode.requestOutputItem(local_parent, scriptNode.receiveOutputItem)
                else:
                    scriptNode.requestOutputSet(local_parent, scriptNode.receiveOutputSet)
    else:
        if local_parent: 
            if scriptNode.transfermode == 'stream':
                scriptNode.requestOutputItem(local_parent, scriptNode.receiveOutputItem)
            else:
                scriptNode.requestOutputSet(local_parent, scriptNode.receiveOutputSet)
    
    for node in scriptNode.allnodes.values():
        node.resolveDelayedRegistrations()
        
    return scriptNode
