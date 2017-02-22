#! /bin/bash

echo "SETUP - Uploading stemcell to Bosh..."
bosh upload stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
echo "SETUP - Successfully uploaded stemcell to Bosh."

# if the cf-release does not exist then skip cloning it
if [ ! -d "../cf-release" ]; then
  echo "SETUP - Cloning cf-release..."
  pushd ../
    git clone https://github.com/cloudfoundry/cf-release.git
  popd
  echo "SETUP - Successfully cloned cf-release."
fi

# if the diego-release does not exist then skip cloning it
if [ ! -d "../diego-release" ]; then
  echo "SETUP - Checking out diego-release and executing update script..."
  pushd ../
    git clone https://github.com/cloudfoundry/diego-release.git
  popd
  echo "SETUP - Successfully checked out diego-release and executed the update script."
fi

echo "SETUP - diego-release executing update script..."
pushd ../diego-release
  ./scripts/update
popd
echo "SETUP - Successfully executed the update script."

echo "SETUP - Generating cf-release manifest file and deploying it to Bosh..."
pushd ../cf-release
  ./scripts/generate-bosh-lite-dev-manifest
  #bosh deployment bosh-lite/deployments/cf.yml
  bosh -n create release --force &&
  bosh -n upload release &&
  bosh -n deploy
popd
echo "SETUP - Successfully generated cf-release manifest file and deployed CF."

echo "SETUP - Generating diego-release manifest file and deploying it to Bosh..."
pushd ../diego-release
  #git checkout master
  #./scripts/generate-bosh-lite-manifests
  export SQL_FLAVOR='postgres'
  ./scripts/generate-bosh-lite-manifests
  # garden runc
  bosh upload release https://bosh.io/d/github.com/cloudfoundry/garden-runc-release
  # cflinuxfs
  bosh upload release https://bosh.io/d/github.com/cloudfoundry/cflinuxfs2-rootfs-release
  bosh deployment bosh-lite/deployments/diego.yml
  bosh -n create release --force &&
  bosh -n upload release &&
  bosh -n deploy
popd
echo "SETUP - Successfully generated diego-release manifest file."

echo "SETUP - Enabling Docker support..."
cf login -a http://api.bosh-lite.com -u admin -p admin --skip-ssl-validation &&
cf enable-feature-flag diego_docker
echo "SETUP - Successfully enabled Docker support."

echo "SETUP - Enabling route to Bosh 10.244.0.0/19 192.168.50.4"
sudo route add -net 10.244.0.0/19 192.168.50.4
echo "SETUP - Successfully enabled route to Bosh 10.244.0.0/19 192.168.50.4"

echo "SETUP - Setup CF API and login..."
cf api --skip-ssl-validation http://api.bosh-lite.com
cf login --skip-ssl-validation -a http://api.bosh-lite.com -u admin
echo "SETUP - Successfully setup CF API and login was successfully."

echo "SETUP - Creating org and space..."
cf create-org apigee
cf target -o apigee
cf create-space myspace
cf target -o "apigee" -s "myspace"
cf orgs
echo "SETUP - Successfully created org and space."

echo "SETUP - Uploading edgemicro-decorator..."
./upload
cf buildpacks
echo "SETUP - Successfully upload edgemicro-decorator"

echo "SETUP - Uploading meta-buildpack..."
pushd ../
  git clone https://github.com/cf-platform-eng/meta-buildpack.git
  pushd meta-buildpack/
  ./build
  ./upload
  popd
popd
cf buildpacks
echo "SETUP - Successfully uploaded meta-buildpack"

echo  "SETUP - cloning the spring boot sample application and configuring it..."
pushd ../
  git clone https://github.com/spring-guides/gs-rest-service.git
popd
cp setup/manifest.yml ../gs-rest-service/complete
echo  "SETUP - Successfully downloaded spring boot application"

echo  "SETUP - Creating Edge Microgateway service and Deploying spring application to Cloud Foundry..."
pushd ../gs-rest-service/complete
cf push --no-start -m 512MB
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "tags": ["edgemicro"]}'
cf bind-service spring_hello edgemicro_service
popd
echo  "SETUP - finished"

echo "SETUP - Installing Diego-Enabler plugin..."
cf install-plugin Diego-Enabler -r CF-Community
cf enable-diego spring_hello
cf start spring_hello
echo "SETUP - Finished installing Diego Enabler."
