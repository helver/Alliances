# Framework Modules
import twisted.web2.http as tw2http
import twisted.web2.resource as resource
import twisted.web2.server as server
import twisted.web2.static as static
import twisted.web2.http_headers as http_headers
import twisted.web2.stream as stream
import twisted.web2.channel as channel
import twisted.internet.reactor as reactor
import twisted.internet.defer as defer
import twisted.python.log as log
import twisted.application.service as service
import twisted.application.internet as internet 
import twisted.application.strports as strports

# Mir Modules
import mir.log_service as log_service
import mir.config as config
import mandiant.utils.call_trace as call_trace
import mir.script_runner.script_runner as script_runner

# load the config for this service
config_data = config.MirConfig("scriptrunner")
do_tracing = config_data.getByPath("script_runner", "tracing_level")

#
# ScriptRunnerWebInterface
#
# Extracted the web resource functionality from the business logic of
# the ScriptRunner class.  Basically, when we get a web request
# we fire up an ScriptRunner object to handle the request.
#
class ScriptRunnerWebInterface(resource.Resource):

    
    @call_trace.CallTrace(log.msg, do_tracing)
    def __init__(self, script_runner, **kwargs):
        resource.Resource.__init__(self)
        self.debug_level = kwargs.has_key("debug_level") and kwargs["debug_level"] or 0
        self.script_runner = script_runner
        
    
    # ScriptRunner.render
    @call_trace.CallTrace(log.msg, do_tracing)
    @defer.inlineCallbacks
    def render(self, request):
        """ render() is called when the script_runner has its newjob method
            invoked.  This is the start of the job execution process."""
            
        log.msg(request, level='minor')
        log.msg(request.args, level='minor')
        
        if request.path == "/newjob":
            new_job_id = request.args["jobhref"][0];
            
            log.msg("Received request to initiate job with href: " + new_job_id, level='major')
        
            job_rec = { "job_identity": new_job_id }
            
            # Invoke the status method with the new_job_id.  This call will start the
            # process of gathering information about the job to be executed.
            yield self.script_runner.initiate(job_rec)
        
            defer.returnValue(tw2http.Response(200, {'content-type': http_headers.MimeType('text', 'plain')}, "Job Initiated"))

        else:
            defer.returnValue(tw2http.Response(404, {'content-type': http_headers.MimeType('text', 'plain')}, "No matching resource."))

    
class ScriptRunnerService(service.Service):

    @call_trace.CallTrace(log.msg, do_tracing)
    def __init__(self, **kwargs):
        self.debug_level = kwargs.has_key("debug_level") and kwargs["debug_level"] or 0
        self.port = kwargs.has_key("port") and kwargs["port"] or config_data.getByPath('script_runner', 'location', 'port')
        self.messageBus = kwargs.has_key("messageBus") and kwargs["messageBus"] or None


    @call_trace.CallTrace(log.msg, do_tracing)
    def startService(self):
        self.script_runner_thing = script_runner.ScriptRunner(debug_level=self.debug_level, mbus=self.messageBus)
        
        if config_data.getByPath('script_runner', 'web_interface_active') == True:
            self.webIf = ScriptRunnerWebInterface(debug_level=self.debug_level, script_runner=self.script_runner_thing)
            root = resource.Resource()
            root.putChild('newjob', self.webIf)
            site = server.Site(root)
            reactor.listenTCP(self.port, channel.HTTPFactory(site))
        
        
    @call_trace.CallTrace(log.msg, do_tracing)
    def stopService(self):
        if hasattr(self, 'webIf'): self.webIf = None
        self.script_runner_thing = None
        
    
if __name__ == "__main__":
    from twisted.internet import reactor
    debug_level = 5
    
    service = ScriptRunnerService(debug_level=debug_level)
    service.startService()
    reactor.run()


