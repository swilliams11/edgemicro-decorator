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


echo Using org and environment configured in /setup/setenv.sh

echo Be sure to run scripts under ./setup/provisioning

source ../setup/setenv.sh

echo Get app profile

echo "Enter your password for the Apigee Enterprise organization $org, followed by [ENTER]:"

while [ -z $password ]; do
	read -s password
done

#########################################################################################################

echo -e "Fetching Callback URL, ConsumerKey & Secret for developer application 'joe-app' \n"
appdata=`curl -k -u "$username:$password" "$url/v1/o/$org/developers/joe@weathersample.com/apps/joe-app" 2>/dev/null`;
callback=`echo "$appdata" | grep callbackUrl | awk -F '\"' '{ print $4 }'`;
consumerkey=`echo "$appdata" | grep -m 1 consumerKey | awk -F '\"' '{ print $4 }'`;
consumersecret=`echo "$appdata" | grep -m 1 consumerSecret | awk -F '\"' '{ print $4 }'`;
boshendpoint="http://rest-service.bosh-lite.com/greeting/"
#########################################################################################################

GrantType_ClientCredentials () {

echo -e "\nPerforming Client Credentials Flow:";
sleep 2

accesstoken_request="https://$org-$env.$api_domain/edgemicro-auth/token"

echo -e "\n	URL: POST $accesstoken_request
	HTTP Headers:
		* Content-Type : application/json
	Payload:  \n\n"

echo "Using the app key $consumerkey and secret $consumersecret to request an access token"

echo -e "curl \"$accesstoken_request\" -X POST -d '{"client_id":"$consumerkey", "secret":"$consumersecret", "grant_type":"client_credentials"}' -H \"Content-Type : application/json\""

accesstoken_response=`curl -X POST -H "Content-type: application/json" "$accesstoken_request" -d "{\"client_id\":\"$consumerkey\", \"client_secret\":\"$consumersecret\", \"grant_type\":\"client_credentials\"}" 2>/dev/null`

echo -e "\n\nAccessToken Response \n $accesstoken_response \n"

#Extracting AccessToken & RefreshToken
#access_token=`echo $accesstoken_response | awk -F "," '{ print $1 }' | awk -F ":" '{print $2}' | sed -e 's/[^a-zA-Z0-9]//g'`
access_token=`echo $accesstoken_response | awk -F "," '{ print $1 }' | awk -F ":" '{print $2}' | grep -o '".*"' | sed -e 's/"//g'`

echo -e "JWT: $access_token"

}

############################################### MAIN FLOW ###############################################
GrantType_ClientCredentials

#########################################################################################################

echo "The access token above is used to make a request to the protected resource."

#########################################################################################################

echo -e "\n\nSending test request to $boshendpoint\n"
echo -e "curl -H \"Authorization: Bearer $access_token\" \"$boshendpoint\" -i"

boshresponse=`curl -H "Authorization: Bearer $access_token" "$boshendpoint" -i`

echo -e "\n\nResponse:\n"
echo -e "$boshresponse"
