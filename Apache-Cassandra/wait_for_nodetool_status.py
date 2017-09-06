import time
import boto3
from st2actions.runners.pythonrunner import Action

# pylint: disable=too-few-public-methods
class nodetool_status(Action):
    def run(self, region, credentials, instanceId):

        client=None
        reponse=None
        Command=None
        CommandId=None
        output_string=""

        if credentials is not None:
            session=boto3.session(
                aws_access_key_id=credentials['Credentials']['AccessKeyId'],
                aws_secret_access_key=credentials['Credentials']['SecretAccessKey'],
                aws_session_token=credentials['Credentials']['SessionToken']
            )
            client = session.client('ssm', region_name=region)
        else:
            client = boto3.client('ssm', region_name=region)
        
        if client is None:
            output_string = "ec2 client creation failed"
            return (False, output_string)

        Command = client.send_command( InstanceIds= [instanceId], DocumentName='AWS-RunShellScript', Comment='nodetool status', Parameters={ "commands":[ "nodetool netstats | grep Mode | awk '{print$2}'" ]  })
        CommandId=Command['Command']['CommandId']

        time.sleep(10)

        response_cmd_invo = client.get_command_invocation( CommandId = CommandId, InstanceId = instanceId )['StandardOutputContent']

        while response_cmd_invo != 'DECOMMISSIONED\n':
            Command = client.send_command( InstanceIds= [instanceId], DocumentName='AWS-RunShellScript', Comment='nodetool status', Parameters={ "commands":[ "nodetool netstats | grep Mode | awk '{print$2}'" ]  })
            CommandId = Command['Command']['CommandId']
            time.sleep(5)
            response_cmd_invo = client.get_command_invocation( CommandId = CommandId, InstanceId = instanceId )['StandardOutputContent']

        return (True, response_cmd_invo)