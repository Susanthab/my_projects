

# getting started
https://gist.github.com/ianunruh/3908fb5eee4fe66c95b4

I downloaded the version to 0.8.1_linux_amd64.zip
curl -OL https://releases.hashicorp.com/consul/0.9.0/consul_0.9.0_linux_amd64.zip

# To start the agent
consul agent -dev -ui -client 192.168.16.20
# client ip is the IP of the vagrant box. 

# To access the web UI
http://192.168.16.21:8500/ui

# Testing
https://www.consul.io/intro/getting-started/kv.html

# Need to create the consul config file for st2
/opt/stackstorm/configs/consul.yaml

--==============================================
### Place configuration data for your pack here.
---
host: '192.168.16.20'
port: 8500
token: e85aa14c-7f45-5fea-f869-ca4eb14caa47
scheme: 'http'
verify: false
--==============================================

# For the token, I copy and paste the Unige ID of consul agent. 
# Host ip is the IP of the vagrant box. 
consul agent -dev -ui -client 192.168.16.21