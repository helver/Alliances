import string

import twisted.internet.defer as defer
import twisted.internet.reactor as reactor

class ACTestIndexer(object):
    """
    Provides the interface to the Mir Resource Database.
    """
    def __init__(self, *args, **kwargs):
        pass
    
    def close(self):
        pass
    
    def callRemote(self, fn, *args, **kwargs):
        showdef = defer.Deferred()
        reactor.callLater(0, lambda x: x.callback(""), showdef)
        
        return showdef


