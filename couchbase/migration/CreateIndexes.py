#!/usr/bin/env python

import requests
import json
import time
import sys

class CreateIndex:

    def __init__(self,source_cluster_endpoint,source_username,source_userpwd,destination_cluster_endpoint,destination_username,destination_userpwd):
      self.s_ep = source_cluster_endpoint
      self.s_user = source_username
      self.s_pwd = source_userpwd
      self.d_ep = destination_cluster_endpoint
      self.d_user = destination_username
      self.d_pwd = destination_userpwd

    def get_all_source_indexes(self):
      response = requests.get('http://%s:8091/indexStatus' % self.s_ep, auth=(self.s_user,self.s_pwd))
      all_indexes = json.loads(response.text)
      return(all_indexes)

    def get_destination_server_node(self):
      response = requests.get('https://%s:18091/pools/nodes' % self.d_ep, auth=(self.d_user,self.d_pwd), verify=False)
      node = (json.loads(response.text)['nodes'][0]['hostname']).split(":")[0]
      return(node)

    def create_index_at_destination(self,indexes,node):
      for i in indexes['indexes']:
        i_definition = i['definition']
        index = i['index']
        b_name = i['bucket']
        #print(i_definition) 
        data = {'statement':i_definition}
        print("Info: Creating index [%s] ON Bucket, [%s]" % (index, b_name))
        response = requests.post('https://%s:18093/query/service' % node, auth=(self.d_user,self.d_pwd), data = data, verify=False)
        if "success" in response.text:
          print "Success: Index created successfully!"
        else:
          print "Error: Index creation failed."
        time.sleep(5)
        data = {'statement': 'BUILD INDEX ON `%s` (`%s`) USING GSI' % (b_name,index)}
        print("Info: Building index...")
        response = requests.post('https://%s:18093/query/service' % node, auth=(self.d_user,self.d_pwd), data = data, verify=False)
        if "success" in response.text:
          print "Success: Build Index is successfull!"
        else:
          print("Error: Build index failed.")
        time.sleep(5)
      return      

def main():
  ind = CreateIndex(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],sys.argv[6])

  indexes = ind.get_all_source_indexes()
  node = ind.get_destination_server_node()
  res = ind.create_index_at_destination(indexes,node)

if __name__ == '__main__': 
   main()