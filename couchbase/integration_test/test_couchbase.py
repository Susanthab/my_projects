#!/usr/bin/env python

import pytest
import unittest
from ..lib import config
import logging

log = logging.getLogger('test_couchbase')

class TestCouchbase(object):

    def test_couchbase_api_response(self):
        """ Verifies we can access the couchbase api """
        cmd = self.couchbaseclient.curl_get("status")
        log.debug(cmd)
        out = self.kubeclient.pod.execute("couchbase-test-runner", cmd)
        assert "200 OK" in out
