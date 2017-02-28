#! /bin/bash

echo  "SETUP - Creating Edge Microgateway service and Deploying spring application to Cloud Foundry..."
pushd ../gs-rest-service/complete
cf push --no-start -m 512MB
cf cups edgemicro_service -p 'REPLACEME'
cf bind-service spring_hello edgemicro_service
popd
echo  "SETUP - finished"

echo "SETUP - Enabling Diego for spring app..."
cf enable-diego spring_hello
cf start spring_hello
echo "SETUP - Finished enabling Diego."
