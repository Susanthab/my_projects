#!/usr/bin/env python

import requests
import json
import time
import sys

class BuildIndex:

    def __init__(self,cluster_endpoint,username,userpwd):
      self.ep = cluster_endpoint
      self.user = username
      self.pwd = userpwd

    def get_all_indexes(self):
      response = requests.get('http://%s:8091/indexStatus' % self.ep, auth=(self.user,self.pwd))
      all_indexes = json.loads(response.text)
      return(all_indexes)

    def build_index(self,indexes):
      for i in indexes['indexes']:
        i_definition = i['definition']
        index = i['index']
        b_name = i['bucket']
        #print(i_definition)
        data = {'statement':i_definition}
        print("Info: Building index [%s] ON Bucket, [%s]" % (index, b_name))
        data = {'statement': 'BUILD INDEX ON `%s` (`%s`) USING GSI' % (b_name,index)}
        print("Info: Building index...")
        response = requests.post('http://%s:8093/query/service' % self.ep, auth=(self.user,self.pwd), data = data)
        if "success" in response.text:
          print "Success: Build Index is successfull!"
        else:
          print("Error: Build index failed.")
        time.sleep(5)
      return

def main():
  ind = BuildIndex(sys.argv[1],sys.argv[2],sys.argv[3])

  indexes = ind.get_all_indexes()
  res = ind.build_index(indexes)

if __name__ == '__main__':
   main()