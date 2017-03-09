#!/bin/bash

set -e
set -x

# set the target
#sudo route add -net 10.244.0.0/19 192.168.50.4
#git clone https://github.com/swilliams11/edgemicro-decorator.git
ls -la
pwd
dpkg -i resource-edgemicro-decorator/test/cf-cli-*.deb && apt-get install -f
ip route add 10.244.0.0/19 via 192.168.50.4 dev eth0
cf api --skip-ssl-validation https://api.bosh-lite.com
cf login --skip-ssl-validation -a https://api.bosh-lite.com -u admin
echo "Executing cf cups..."
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"demo", "env":"test", "user":"sw@email.com","pass":"password", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "onpremises": "true", "onprem_config" : {"runtime_url": "http://192.168.56.101:9001", "mgmt_url" : "http://192.168.56.101:8080", "virtual_host" : "default"}, "yaml_included":"true","yaml_name":"demo-test-config.yaml", "tags": ["edgemicro"]}'
