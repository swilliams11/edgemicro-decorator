#!/bin/bash

set -e -x


# set the target
#sudo route add -net 10.244.0.0/19 192.168.50.4

# upload the decorator

# restage the application

# execute the test scripts

#pushd edgemicro-decorator
  # test the yaml file code
  cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"demo", "env":"test", "user":"sw@email.com","pass":"password", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "onpremises": "true", "onprem_config" : {"runtime_url": "http://192.168.56.101:9001", "mgmt_url" : "http://192.168.56.101:8080", "virtual_host" : "default"}, "yaml_included":"true","yaml_name":"demo-test-config.yaml", "tags": ["edgemicro"]}'
  bundle install
  bundle exec rspec
#popd
