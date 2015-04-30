import string

import twisted.internet.defer as defer
import twisted.internet.reactor as reactor
import mir.models as models
import re
import mir.identity as identity

database = "/usr/lib/python2.5/site-packages/mir/script_runner/test/"

job_script = file(database + "data/job_scripts/basic_agent_1.xml").read()

job_schedule = "now"

job_input_uri_list = "<input><uri>/workspaces/1/hosts/resources/1/</uri>\n<uri>/workspaces/1/hosts/resources/2/</uri></input>"

def build_job_xml():
    return '%s%s\n<when>%s</when>\n%s\n</JobDefinition>' % (
             '<?xml version="1.0"?>\n<JobDefinition xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" href="/workspaces/1/jobs/234/">',
             job_script,
             job_schedule,
             job_input_uri_list,
          )

job_xml = build_job_xml()



class DummyJobQuery(object):
    def __init__(self, *args, **kwargs):
        global job_script
        global job_xml
        
        if kwargs.has_key('scriptfile'):
            job_script = file(database + "data/job_scripts/%s" % kwargs['scriptfile']).read()
            job_xml = build_job_xml()
            
    def select_by(self, *args, **kwargs):
        return [models.Job("ScriptRunner TestJob #1", schedule=job_schedule, input=job_input_uri_list, script=job_script, workspace_id=1, id=kwargs["id"])]

class DummyHostQuery(object):
    def __init__(self, *args, **kwargs):
        global job_script
        global job_xml
        
        if kwargs.has_key('scriptfile'):
            job_script = file(database + "data/job_scripts/%s" % kwargs['scriptfile']).read()
            job_xml = build_job_xml()
            
    def select_by(self, *args, **kwargs):
        if kwargs.has_key('href'):
            queryset = []
            for href in kwargs['href']:
                id = identity.identity_from_string(href).id
                address = '127.0.0.%s:22201' % id
                queryset.append(models.Host('Host ##%s' % id, workspace_id=kwargs["workspace_id"], id=id, address=address))
            return queryset
        else:
            address = '127.0.0.1:22201'
            return [models.Host('Host ##1', workspace_id=kwargs["workspace_id"], id=kwargs["id"], address=address)]

class DummySession(object):
    def __init__(self, *args, **kwargs):
        self.kwargs = kwargs

    def query(self, model_type):
        if model_type == models.Job:
            return DummyJobQuery(**self.kwargs)
        if model_type == models.Host:
            return DummyHostQuery(**self.kwargs)
        
    def save_or_update(self, *args, **kwargs):
        pass
    
    def flush(self, *args, **kwargs):
        pass

    def clear(self, *args, **kwargs):
        pass

    def save(self, *args, **kwargs):
        pass

    def update(self, *args, **kwargs):
        pass

    def refresh(self, *args, **kwargs):
        pass

    def save_or_update(self, *args, **kwargs):
        pass


class ACTestObjectDB(object):
    """
    Provides the interface to the Mir Resource Database.
    """
    def __init__(self, *args, **kwargs):
        self.session = DummySession(args, **kwargs)
    
    def close(self):
        pass
    
    def defer_to_session(self, fn, *args, **kwargs):
        showdef = defer.Deferred()
        
        fn(self, self.session, *args, **kwargs)
        reactor.callLater(0, lambda x: x.callback(""), showdef)
        
        return showdef


