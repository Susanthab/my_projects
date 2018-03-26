
        
        
        
        Command = client.send_command( InstanceIds= [instanceId], DocumentName='AWS-RunShellScript', Comment='Couchbase host-list', Parameters={ "commands":[ "/opt/couchbase/bin/couchbase-cli host-list --cluster " + server_remove_ip + " -u " + username + " -p " + password + " | grep -v " + server_remove_ip + " | head -n 1" + "" ] })

        CommandId = Command['Command']['CommandId']

        time.sleep(10)

        cluster_ip_port = client.get_command_invocation( CommandId = CommandId, InstanceId = instanceId )['StandardOutputContent']
        cluster_ip = cluster_ip_port.split(':', 1)[0]
        print cluster_ip

        rebalance = client.send_command( InstanceIds= [instanceId], DocumentName='AWS-RunShellScript', Comment='Couchbase rebalance', Parameters={ "commands":[ "/opt/couchbase/bin/couchbase-cli rebalance -c " + cluster_ip + " -u " + username + " -p " + password + " --server-remove=" + server_remove_ip + "" ] })

        CommandId_Rebalance = rebalance['Command']['CommandId']


        time.sleep(30)

        response_cmd_invo_rebalance = client.get_command_invocation( CommandId = CommandId_Rebalance, InstanceId = instanceId )['StandardOutputContent']

        while True:
          if 'ERROR' in response_cmd_invo_rebalance:
            retrun=False
            break

          if 'SUCCESS' in response_cmd_invo_rebalance:
            retrun=True
            break

          time.sleep(10)
          response_cmd_invo_rebalance = client.get_command_invocation( CommandId = CommandId_Rebalance, InstanceId = instanceId )['StandardOutputContent']