#!/bin/bash

#Copyright 2018 Google LLC

#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at

#    https://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

source ./config.sh

set -e
set -x

# set the target
sudo route add -net 10.244.0.0/19 192.168.50.4
#ip route add 10.244.0.0/19 via 192.168.50.4 dev eth0ss
cf api --skip-ssl-validation $cf_hostname
cf login --skip-ssl-validation -a $cf_hostname -u $cf_admin -p $cf_adminpw -o $cf_org -s $cf_space

echo "update the security groups"
cf update-security-group public_networks ../setup/cf_securitygroups/public_networks2.json
cf update-security-group load_balancer ../setup/cf_securitygroups/load_balancer.json
cf update-security-group services ../setup/cf_securitygroups/services.json
cf update-security-group user_bosh_deployments ../setup/cf_securitygroups/user_bosh_deployments.json

echo "******** 1st Test - Default Configuration *********"
cf uups edgemicro_service -p "{\"application_name\":\"edgemicro_service\", \"org\":\"$org\", \"env\":\"$env\", \"user\":\"$username\",\"pass\":\"$password\", \"edgemicro_version\":\"$edgemicro_version\", \"edgemicro_port\":\"$edgemicro_port\", \"onpremises\": \"true\", \"onprem_config\" : {\"runtime_url\": \"$edge_runtimeurl\", \"mgmt_url\" : \"$edge_mgmturl\", \"virtual_host\" : \"default\"}, \"tags\": [\"edgemicro\"]}"
cf restage spring_hello
sleep 60 #30 seconds

# get the access token
tokenResponse=`curl -X POST $edge_runtimeurl/edgemicro-auth/token -H "Content-type: application/json" -d "{\"client_id\":\"$client_id\",\"client_secret\":\"$client_secret\",\"grant_type\":\"client_credentials\"}"`
token=$(sed -n 's/token: \(.*\)/\1 /p' <<< "$tokenResponse")
token=`echo "$tokenResponse" | sed -n 's/"token": \(.*\)/\1 /p' | tr -d '"' | sed 's/^ *//;s/ *$//'`

response=`curl http://rest-service.bosh-lite.com/edgemicro_hello/greeting -H "Authorization: Bearer $token"`

while [ $response == "404 Not Found: Requested route ('rest-service.bosh-lite.com') does not exist." ]
do
  cf restart spring_hello
  sleep 60 #30 seconds
  response=`curl http://rest-service.bosh-lite.com/edgemicro_hello/greeting -H "Authorization: Bearer $token"`
done

if [[ $response == *"Hello, World"* ]]; then
  echo "PASSED Test"
fi


echo "******** 2nd Test - Spike Arrest *********"
#cf delete-service edgemicro_service
cf uups edgemicro_service -p "{\"application_name\":\"edgemicro_service\", \"org\":\"$org\", \"env\":\"$env\", \"user\":\"$username\",\"pass\":\"$password\", \"edgemicro_version\":\"$edgemicro_version\", \"edgemicro_port\":\"$edgemicro_port\", \"onpremises\": \"true\", \"onprem_config\" : {\"runtime_url\": \"$edge_runtimeurl\", \"mgmt_url\" : \"$edge_mgmturl\", \"virtual_host\" : \"default\"}, \"enable_spike_arrest\": \"true\", \"spike_arrest_config\" : {\"timeunit\": \"minute\", \"allow\" : \"5\"}, \"tags\": [\"edgemicro\"]}"

cf restage spring_hello
#echo "waiting for spring_hello to be restaged..."
sleep 60 #30 seconds

curl http://rest-service.bosh-lite.com/edgemicro_hello/greeting -H "Authorization: Bearer $token"
#this response should succeed
response=`curl http://rest-service.bosh-lite.com/edgemicro_hello/greeting -H "Authorization: Bearer $token"`
#this request should fail
response=`curl http://rest-service.bosh-lite.com/edgemicro_hello/greeting -H "Authorization: Bearer $token"`


#cucumber-js features/edgemicro.feature
#force wait here to make sure the app is deployed


echo "******** 3nd Test - YAML *********"
#cf delete-service edgemicro_service
cf uups edgemicro_service -p "{\"application_name\":\"edgemicro_service\", \"org\":\"$org\", \"env\":\"$env\", \"user\":\"$username\",\"pass\":\"$password\", \"edgemicro_version\":\"$edgemicro_version\", \"edgemicro_port\":\"$edgemicro_port\", \"onpremises\": \"true\", \"onprem_config\" : {\"runtime_url\": \"$edge_runtimeurl\", \"mgmt_url\" : \"$edge_mgmturl\", \"virtual_host\" : \"default\"}, \"yaml_included\":\"true\",\"yaml_name\":\"demo-test-config.yaml\", \"tags\": [\"edgemicro\"]}"

#cf restage spring_hello
#echo "waiting for spring_hello to be restaged..."
#sleep 30 #30 seconds

#cucumber-js features/edgemicro.feature
#force wait here to make sure the app is deployed
