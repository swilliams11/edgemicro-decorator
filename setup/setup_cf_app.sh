#! /bin/bash
source ./test/config.sh

echo  "SETUP - Creating Edge Microgateway service and Deploying spring application to Cloud Foundry..."
cf api --skip-ssl-validation $cf_hostname
cf login --skip-ssl-validation -a $cf_hostname -u $cf_admin -p $cf_adminpw -o $cf_org -s $cf_space

pushd ../gs-rest-service/complete
if [ ! -d "build" ]; then
  gradle build
fi
cf push --no-start -m 512MB
cf cups edgemicro_service -p 'REPLACEME'
cf bind-service spring_hello edgemicro_service
popd
echo  "SETUP - finished"

echo "SETUP - Enabling Diego for spring app..."
cf enable-diego spring_hello
cf start spring_hello
echo "SETUP - Finished enabling Diego."
