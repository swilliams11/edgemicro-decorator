#!/bin/bash
source ./config.sh

set -e
set -x
TEST=$1
# set the target
#sudo route add -net 10.244.0.0/19 192.168.50.4
#ip route add 10.244.0.0/19 via 192.168.50.4 dev eth0ss
cf api --skip-ssl-validation $cf_hostname
cf login --skip-ssl-validation -a $cf_hostname -u $cf_admin -p $cf_adminpw -o $cf_org -s $cf_space

#if [ ! -d "gs-rest-service" ]; then
#  git clone https://github.com/spring-guides/gs-rest-service.git
#else
#  rm -rf gs-rest-service
#  git clone https://github.com/spring-guides/gs-rest-service.git
#fi

#pushd gs-rest-service/complete
#  gradle build
#popd

#delete meta-buildpack
cf delete-buildpack meta_buildpack -f
cf delete-buildpack edgemicro_decorator -f

pushd ../../meta-buildpack/
  ./upload
popd

pushd ../
  ./upload
popd

echo "update the security groups"
#cf update-security-group public_networks ../setup/cf_securitygroups/public_networks2.json
#cf update-security-group load_balancer ../setup/cf_securitygroups/load_balancer.json
#cf update-security-group services ../setup/cf_securitygroups/services.json
#cf update-security-group user_bosh_deployments ../setup/cf_securitygroups/user_bosh_deployments.json

#make sure we have a clean environment before we test.
cf delete spring_hellotest -f
cf delete-service edgemicro_service -f
#create the default instance so that it exists, and subsequents updates don't fail
cf cups edgemicro_service -p "{\"application_name\":\"edgemicro_service\", \"org\":\"$org\", \"env\":\"$env\", \"user\":\"$username\",\"pass\":\"$password\", \"edgemicro_version\":\"$edgemicro_version\", \"edgemicro_port\":\"$edgemicro_port\", \"onpremises\": \"true\", \"onprem_config\" : {\"runtime_url\": \"$edge_runtimeurl\", \"mgmt_url\" : \"$edge_mgmturl\", \"virtual_host\" : \"default\"}, \"tags\": [\"edgemicro\"]}"
pushd gs-rest-service/complete
  cf push --no-start
  cf enable-diego spring_hellotest
  cf bind-service spring_hellotest edgemicro_service
popd

if [ "$TEST" == "all" ] || [ "$TEST" == "test1" ]; then
  echo "******** 1 Test - Default Configuration *********"
  cf uups edgemicro_service -p "{\"application_name\":\"edgemicro_service\", \"org\":\"$org\", \"env\":\"$env\", \"user\":\"$username\",\"pass\":\"$password\", \"edgemicro_version\":\"$edgemicro_version\", \"edgemicro_port\":\"$edgemicro_port\", \"onpremises\": \"true\", \"onprem_config\" : {\"runtime_url\": \"$edge_runtimeurl\", \"mgmt_url\" : \"$edge_mgmturl\", \"virtual_host\" : \"default\"}, \"tags\": [\"edgemicro\"]}"
  #pushd gs-rest-service/complete
    #sed -ie 's/name: gs-rest-service/name: spring_hello/' manifest.yml
    #sed -ie 's/guides.spring.io/bosh-lite.com/' manifest.yml
  #  cf push
  #popd
  cf start spring_hellotest
  sleep 30 #seconds
  cucumber-js features/edgemicro.feature
fi

if [ "$TEST" == "all" ] || [ "$TEST" == "test2" ]; then
  echo "******** 2 Test - Spike Arrest *********"
  cf uups edgemicro_service -p "{\"application_name\":\"edgemicro_service\", \"org\":\"$org\", \"env\":\"$env\", \"user\":\"$username\",\"pass\":\"$password\", \"edgemicro_version\":\"$edgemicro_version\", \"edgemicro_port\":\"$edgemicro_port\", \"onpremises\": \"true\", \"onprem_config\" : {\"runtime_url\": \"$edge_runtimeurl\", \"mgmt_url\" : \"$edge_mgmturl\", \"virtual_host\" : \"default\"}, \"enable_spike_arrest\": \"true\", \"spike_arrest_config\" : {\"timeunit\": \"minute\", \"allow\" : \"$SPIKE_ARREST_RATE\"}, \"tags\": [\"edgemicro\"]}"

  #cf restage spring_hellotest
  pushd gs-rest-service/complete
    cf push
  popd
  sleep 30
  cucumber-js features/edgemicroSpikeArrest.feature
fi

if [ "$TEST" == "all" ] || [ "$TEST" == "test3" ]; then
  echo "******** 3 Test - enable custom plugins *********"
  cf uups edgemicro_service -p "{\"application_name\":\"edgemicro_service\", \"org\":\"$org\", \"env\":\"$env\", \"user\":\"$username\",\"pass\":\"$password\", \"edgemicro_version\":\"$edgemicro_version\", \"edgemicro_port\":\"$edgemicro_port\", \"onpremises\": \"true\", \"onprem_config\" : {\"runtime_url\": \"$edge_runtimeurl\", \"mgmt_url\" : \"$edge_mgmturl\", \"virtual_host\" : \"default\"}, \"enable_custom_plugins\":\"true\", \"plugins\":\"oauth,plugin1,plugin2\", \"yaml_included\":\"false\",\"tags\": [\"edgemicro\"]}"
  #make sure plugin1 and plugin2 are uploaded with the decorator before testing
  pushd ../
    ./upload
  popd
  pushd gs-rest-service/complete
    cf push
  popd
  #cf restage spring_hellotest
  sleep 30
  cucumber-js features/edgemicroCustomPlugins.feature
fi

if [ "$TEST" == "all" ] || [ "$TEST" == "test4" ]; then
  echo "******** 4 Test - enable custom plugins and spike arrest *********"
  cf uups edgemicro_service -p "{\"application_name\":\"edgemicro_service\", \"org\":\"$org\", \"env\":\"$env\", \"user\":\"$username\",\"pass\":\"$password\", \"edgemicro_version\":\"$edgemicro_version\", \"edgemicro_port\":\"$edgemicro_port\", \"onpremises\": \"true\", \"onprem_config\" : {\"runtime_url\": \"$edge_runtimeurl\", \"mgmt_url\" : \"$edge_mgmturl\", \"virtual_host\" : \"default\"}, \"enable_custom_plugins\":\"true\", \"plugins\":\"oauth,spikearrest,plugin1,plugin2\", \"spike_arrest_config\" : {\"timeunit\": \"minute\", \"allow\" : \"$SPIKE_ARREST_RATE\"}, \"tags\": [\"edgemicro\"]}"
  pushd gs-rest-service/complete
    cf push
  popd
  #cf restage spring_hellotest
  sleep 30
  cucumber-js features/edgemicroCustomPlugins.feature
  sleep 15
  cucumber-js features/edgemicroSpikeArrest.feature
fi

if [ "$TEST" == "all" ] || [ "$TEST" == "test5" ]; then
  echo "******** 5 Test - include yaml *********"
  cf uups edgemicro_service -p "{\"application_name\":\"edgemicro_service\", \"org\":\"$org\", \"env\":\"$env\", \"user\":\"$username\",\"pass\":\"$password\", \"edgemicro_version\":\"$edgemicro_version\", \"edgemicro_port\":\"$edgemicro_port\", \"onpremises\": \"true\", \"onprem_config\" : {\"runtime_url\": \"$edge_runtimeurl\", \"mgmt_url\" : \"$edge_mgmturl\", \"virtual_host\" : \"default\"}, \"yaml_included\":\"true\",\"yaml_name\":\"$YAML_FILE\", \"tags\": [\"edgemicro\"]}"
  pushd gs-rest-service/complete
    cf push
  popd
  sleep 30
  cucumber-js features/edgemicroCustomPluginsIncludeYaml.feature
fi

if [ "$TEST" == "all" ] || [ "$TEST" == "test6" ]; then
  echo "******** 6 Test - Enable Quota *********"
  cf uups edgemicro_service -p "{\"application_name\":\"edgemicro_service\", \"org\":\"$org\", \"env\":\"$env\", \"user\":\"$username\",\"pass\":\"$password\", \"edgemicro_version\":\"$edgemicro_version\", \"edgemicro_port\":\"$edgemicro_port\", \"onpremises\": \"true\", \"onprem_config\" : {\"runtime_url\": \"$edge_runtimeurl\", \"mgmt_url\" : \"$edge_mgmturl\", \"virtual_host\" : \"default\"}, \"enable_quota\":\"true\", \"tags\": [\"edgemicro\"]}"
  pushd gs-rest-service/complete
    cf push
  popd
  sleep 30
  cucumber-js features/edgemicroQuota.feature
fi

if [ "$TEST" == "all" ] || [ "$TEST" == "test7" ]; then
  echo "******** 7 Test - Enable Spike Arrest and Quota *********"
  cf uups edgemicro_service -p "{\"application_name\":\"edgemicro_service\", \"org\":\"$org\", \"env\":\"$env\", \"user\":\"$username\",\"pass\":\"$password\", \"edgemicro_version\":\"$edgemicro_version\", \"edgemicro_port\":\"$edgemicro_port\", \"onpremises\": \"true\", \"onprem_config\" : {\"runtime_url\": \"$edge_runtimeurl\", \"mgmt_url\" : \"$edge_mgmturl\", \"virtual_host\" : \"default\"}, \"enable_quota\":\"true\", \"enable_spike_arrest\": \"true\", \"spike_arrest_config\" : {\"timeunit\": \"minute\", \"allow\" : \"$SPIKE_ARREST_RATE\"}, \"tags\": [\"edgemicro\"]}"
  pushd gs-rest-service/complete
    cf push
  popd
  sleep 30
  cucumber-js features/edgemicroSpikeArrest.feature
  cf uups edgemicro_service -p "{\"application_name\":\"edgemicro_service\", \"org\":\"$org\", \"env\":\"$env\", \"user\":\"$username\",\"pass\":\"$password\", \"edgemicro_version\":\"$edgemicro_version\", \"edgemicro_port\":\"$edgemicro_port\", \"onpremises\": \"true\", \"onprem_config\" : {\"runtime_url\": \"$edge_runtimeurl\", \"mgmt_url\" : \"$edge_mgmturl\", \"virtual_host\" : \"default\"}, \"enable_quota\":\"true\", \"enable_spike_arrest\": \"true\", \"spike_arrest_config\" : {\"timeunit\": \"second\", \"allow\" : \"500\"}, \"tags\": [\"edgemicro\"]}"
  cf restage spring_hellotest
  sleep 30
  cucumber-js features/edgemicroQuota.feature
fi
