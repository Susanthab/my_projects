
## https://github.com/stackstorm/st2vagrant
# What I did to spin-up st2vagrant box. 

1. Change the Vagrant file to have a different name for the hostname(st2vagrant2)

2. Clear cache of the browser and log into web portal. (https://192.168.16.20)

3. Sometime you have to set the new auth token. 
    # If the authentication token expired. 
    export ST2_AUTH_TOKEN=`st2 auth -t -p Ch@ngeMe st2admin`

4. Install aws st2 pack.

st2 pack install aws

5. Configure config.yaml file for aws with AWS credentials. 

/opt/stackstorm/packs/aws/config.yaml

Note: I continuosly get "Unable to locate" credentials when running aws pack commands via st2. 
So I decided to install awscli

6. Install awscli. 

sudo apt install awscli

7. Configure awscli

aws configure

8. sudo apt install tree




--=======================================

# Register the action
st2 action create /opt/stackstorm/packs/mongo/actions/create_mongo_replset.meta.yaml
# Check it is available
st2 action list --pack=examples
# Run it
st2 run examples.echochain


#https://docs.stackstorm.com/reference/packs.html?highlight=hello_st2#creating-your-first-pack
##https://docs.stackstorm.com/start.html
# Copy examples to st2 content directory
sudo cp -r /usr/share/doc/st2/examples/ /opt/stackstorm/packs/

# Run setup
st2 run packs.setup_virtualenv packs=mongo

# Reload stackstorm context
st2ctl reload --register-all