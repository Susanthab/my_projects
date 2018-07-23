import logging
logger = logging.getLogger("couchbase")

class Endpoint(object):
    def __init__(self,host,scheme,port):
        self.host = host
        self.port = port 
        self.scheme = scheme
    
    def curl_get(self, uri):
        cmd = "curl -vgsk --show-error --max-time 15 -XGET '{}'".format(self.url(uri))
        logger.debug(cmd)
        return cmd
    
    def url(self, uri):
        return "{}://{}:{}/{}".format(self.scheme,self.host,self.port,uri)



