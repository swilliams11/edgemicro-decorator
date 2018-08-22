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

org="CHANGEME"
username="CHANGEME"
password="CHANGEME"
env="CHANGEME"
#public cloud customers
#edge_runtimeurl="https://api.enterprise.apigee.com"

#cloud
edge_runtimeurl="http://CHANGEME:9001"
edge_mgmturl="http://CHANGEME:8080"

#local
#edge_runtimeurl="http://192.168.56.101:9001"
#edge_mgmturl="http://192.168.56.101:8080"

cf_org="pcfdev-org"
cf_space="pcfdev-space"
#cf_org="apigee"
#cf_space="myspace"
cf_admin="admin"
cf_adminpw="admin"
#cf_hostname="https://api.bosh-lite.com"
cf_hostname="https://api.local.pcfdev.io"
edgemicro_version="2.3.1"
edgemicro_port="8080"
client_id="CHANGEME"
client_secret="CHANGEME"

SPIKE_ARREST_RATE="5"
YAML_FILE="$org-$env-config.yaml"


## Do not change the settings below
## --------------------------------------
export org=$org
export username=$username
export env=$env
export url=$url
export api_domain=$api_domain
