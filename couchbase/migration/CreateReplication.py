#!/usr/bin/env python

import requests
import json
import time
import sys

class CreateReplication:

    def __init__(self,source_cluster_endpoint,source_username,source_userpwd,destination_cluster_endpoint,destination_username,destination_userpwd):
      self.s_ep = source_cluster_endpoint
      self.s_user = source_username
      self.s_pwd = source_userpwd
      self.d_ep = destination_cluster_endpoint
      self.d_user = destination_username
      self.d_pwd = destination_userpwd

    def get_source_buckets(self):
      buckets_res = requests.get('http://%s:8091/pools/default/buckets' % self.s_ep, auth=(self.s_user,self.s_pwd))
      buckets = json.loads(buckets_res.text)
      return(buckets)

    def create_buckets_at_destination(self,bkts):
      for b in bkts:
        name = b['name']
        print('INFO: Creating Bucket %s @ destination server' % name)
        print('****************************************************')
        ramQuotaMB = b['quota']['rawRAM']/1024/1024
        numReplicas = b['vBucketServerMap']['numReplicas']
        data = {'name':name,'ramQuotaMB':ramQuotaMB,'replicaNumber':numReplicas}
        response = requests.post('https://%s:18091/pools/default/buckets' % self.d_ep, auth=(self.d_user,self.d_pwd), data=data, verify=False)
        print(response.text)
        time.sleep(5)
      return

    def get_remote_server_node(self):
      response = requests.get('https://%s:18091/pools/nodes' % self.d_ep, auth=(self.d_user,self.d_pwd), verify=False)
      node = (json.loads(response.text)['nodes'][0]['hostname']).split(":")[0]
      return(node)

    def add_remote_server(self,remote_serer_name, remote_node):
      print('INFO: Adding remote server')
      print('***************************')
      data = {'name':remote_serer_name,'hostname':remote_node,'username':self.d_user,'password':self.d_pwd}
      response = requests.post('http://%s:8091/pools/default/remoteClusters' % self.s_ep, auth=(self.s_user,self.s_pwd), data=data, verify=False)     
      print(response.text)
      return

    def create_xdcr(self,toCluster,bkts):
      for b in bkts:
        name = b['name']
        print('INFO: Creaing replication link for Bucket %s' % name)
        print('***************************************************')
        data = {'fromBucket':name,'toCluster':toCluster,'toBucket':name,'replicationType':'continuous'}
        response = requests.post('http://%s:8091/controller/createReplication' % self.s_ep, auth=(self.s_user,self.s_pwd), data=data)      
        time.sleep(5)
        print(response.text)
      return

def main():
  xdcr = CreateReplication(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],sys.argv[6])

  buckets = xdcr.get_source_buckets()
  a = xdcr.create_buckets_at_destination(buckets)
  print(a)

  remote_node = xdcr.get_remote_server_node()
  print(remote_node)

  time.sleep(10)
  b = xdcr.add_remote_server('remote1', remote_node)
  print(b)
  time.sleep(10)
  c = xdcr.create_xdcr('remote1',buckets)
  print(c)

if __name__ == '__main__': 
   main()