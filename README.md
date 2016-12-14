# Apigee Edge Microgateway Decorator

This is a [decorator](https://github.com/guidowb/meta-buildpack/blob/master/README.md#decorators) buildpack for Cloud Foundry that provides integration with the Apigee Edge API Management via the Edge Microgateway.

When this decorator and the [meta-buildpack](https://github.com/guidowb/meta-buildpack))
is present in your Cloud Foundry deployment, you can select the 'Microgateway' service plan from the Apigee Edge service broker. With that service plan you can automatically add Apigee API Management via the Microgateway.

# Summary
The reason we developed an [Edge Microgateway](http://docs.apigee.com/microgateway/latest/overview-edge-microgateway) decorator is to allow customers running Cloud Foundry to protect their microservices with Apigee, which automatically gets you OAuth 2.0, rate limiting with spike arrests and quotas, and analytics to monitor your run-time traffic.  The Edge Microgateway decorator will run inside the same container that executes the App, which significantly reduces the latency.  The following documentation describes how to test this decorator in a Bosh-lite instance protecting a sample Spring Boot application.

Please note the following:
* Edge Microgateway is listening on port 8080
* [Spring Boot sample application](https://github.com/spring-guides/gs-rest-service) is listening on port 8090 and you can view the [docs here](https://spring.io/guides/gs/rest-service/).
* Cloud Foundry creates an HTTP route to the app based on the Manifest.yml file located in the spring_hello App
* Apps that use the HTTP route are required to listed on port 8080 (will validate)
* This repo uses Edge Microgateway version 2.3.1


## What is the additional space required for my container?
Edge Microgateway is a Node.js application that includes other node libraries as well. Therefore, the total additional space required is the total space for the Node.js runtime, the core Microgateway and all of the required node modules.  
* Node.js v6.9.1-linux-x64 - ~48MB
* Edge Microgateway v2.1.2 (including node_modules) - ~103MB
* Edge Microgateway v2.3.1 (including node_modules) - ~103MB

## What files are included in the edgemicro-decorator?
There are several files that are include:
* `lib` directory
  * apigee-edge-micro.zip - older version of microgateway 1.0 (will be removed)
  * microgateway-2.1.2.zip - includes all the required node_modules for Microgateway to run
  * microgateway-2.3.1.zip - includes all the required node_modules for Microgateway to run
  * microgateway-2.1.2min.zip - only includes the core Microgateway.  This requires that `npm install` is executed to install the required node modules.
  * node-v6.9.1-linux-x64.tar.xz - Node.js runtime
  * node-v6.9.1.tar.gz - Node.js runtime (will be removed)
  * nodejs.sh - copied to `profile.d` directory during the compile phase; sets environment variables
  * zz_micro_config.sh - copied to `profile.d` directory; it sets environment variables and starts Microgateway before CF starts the actual application.  
* `bin` directory
  * compile - script that installs Node.js, and Microgateway; initializes and configures Microgateway.
  * decorate - determines if this decorator should run
  * detect - always returns false
* `upload` - uploads this decorator to CF

## What is the additional latency to proxy requests via Microgateway running on the same VM as my app?
* See the [Gatling tests](#gatling-tests) below

## How much memory is required to run Edgemicro in my container?
When I ran EM v2.1.2 in CF Diego architecture it was able to run within a 256MB container.  However, when I switched to EM 2.3.1, the container failed on startup and there were out-of-memory error messages.  I increased the container memory to 512MB and then the container started successfully.  

* Edge Microgateway v2.1.2 - TODO

* Edge Microgateway v2.3.1
Snapshot of container memory consumption immediately after startup.
```
state     since                    cpu    memory           disk           details
#0   running   2016-12-13 11:38:54 AM   0.9%   406.8M of 512M   297.9M of 1G
```

Snapshot of container memory consumption no requests
```
state     since                    cpu    memory      disk      details
#0   running   2016-12-13 11:49:49 AM   0.0%   0 of 512M   0 of 1G
```

# Prerequisites
1. You should have an Apigee Edge account (private or public).
2. You should [create an Apigee Edge Microgateway](http://docs.apigee.com/microgateway/latest/setting-and-configuring-edge-microgateway#Part2) aware proxy.
   * Proxy base path should be /greeting
   * Target should be http://localhost:8090/greeting
   * You should configure the following paths in your Apigee Edge Microgateway product: `/greeting`, `/greeting/**`.
3. You should install [Bosh-lite](https://github.com/cloudfoundry/bosh-lite).

# What You Need To Know
The following steps will provide you with all the information that you need to setup Cloud Foundry in Bosh-lite.  

## 1. Deploying Cloud Foundry
https://docs.cloudfoundry.org/deploying/boshlite/create_a_manifest.html

## 2. Install Go
https://golang.org/

### Set Go Environment Variable
```
export GOPATH=/usr/local/go
```

## 3. Install Spiff
Spiff if used by the CF deployment scripts to combine manifest files.  

```sh
brew tap xoebus/homebrew-cloudfoundry
brew install spiff
spiff
```

## 4. Deploy Cloud Foundry
https://docs.cloudfoundry.org/deploying/common/deploy.html

### Diego Architecture
Documentation regarding deployment and configuring Diego to run within Bosh-lite is found here.
https://github.com/cloudfoundry/diego-release

Explicit instructions to deploy CF and Diego to Bosh-lite are found here.
https://github.com/cloudfoundry/diego-release/tree/develop/examples/bosh-lite

#### Postgres
Step 7 in the above link prompts you to select between MySQL and Postgres.  I tried the MySQL option but that generated an error so I decided to use the Postgres option instead.  Need to go back and determine why this option did not work. I think it might require the use of another Github repository to install the MySQL service within CF.  


## 5. Add Routes
```
sudo route add -net 10.244.0.0/19 192.168.50.4
```

## 6. Setup the CF API
```
cf api --skip-ssl-validation https://api.bosh-lite.com
```

## 7. Login to the API
```
cf login --skip-ssl-validation -a https://api.bosh-lite.com -u admin
```

### Configure Cloud Foundry

#### Create an Org
```
cf create-org orgname

cf target -o orgname
```
Result:
```
API endpoint:   https://api.bosh-lite.com (API version: 2.65.0)
User:           admin
Org:            orgname
Space:          No space targeted, use 'cf target -s SPACE'
```

#### Create a space
```
cf create-space myspace
```
Result:

```
Creating space myspace in org orgname as admin...
OK
Assigning role RoleSpaceManager to user admin in org orgname / space myspace as admin...
OK
Assigning role RoleSpaceDeveloper to user admin in org orgname / space myspace as admin...
OK

TIP: Use 'cf target -o "orgname" -s "myspace"' to target new space
```

Set the target to the new space.
```
cf target -o "orgname" -s "myspace"
```

List all orgs
```
cf orgs
```

## 8. Upload edgemicro-decorator
Clone this repository
```
git clone https://github.com/swilliams11/edgemicro-decorator.git
```

Upload the decorator to CF.
```
cd edgemicro-decorator
./upload
```

Verify the decorator was uploaded.
```
cf buildpacks
```

Response:
```
buildpack               position   enabled   locked   filename
staticfile_buildpack    1          true      false    staticfile_buildpack-cached-v1.3.12.zip
java_buildpack          2          true      false    java-buildpack-v3.10.zip
ruby_buildpack          3          true      false    ruby_buildpack-cached-v1.6.27.zip
nodejs_buildpack        4          true      false    nodejs_buildpack-cached-v1.5.22.zip
go_buildpack            5          true      false    go_buildpack-cached-v1.7.14.zip
python_buildpack        6          true      false    python_buildpack-cached-v1.5.11.zip
php_buildpack           7          true      false    php_buildpack-cached-v4.3.21.zip
binary_buildpack        8          true      false    binary_buildpack-cached-v1.0.5.zip
dotnet_core_buildpack   9          true      false    dotnet-core_buildpack-cached-v1.0.4.zip
edgemicro_decorator     10         true      false    edgemicro_decorator.zip
```

## 9. Upload meta-buildpack
You must upload the meta-buildpack to CF for this to work.
https://github.com/cf-platform-eng/meta-buildpacks

```
git clone https://github.com/cf-platform-eng/meta-buildpack.git
cd meta-buildpack
./build
./upload
```

Verify that the meta-buildpack was uploaded to CF.
```
cf buildpacks
```

## 10. Clone a Sample Spring Boot application
This is a sample Spring Boot application that I used to test the edgemicro-decorator. Follow the instructions listed in the Github README file to build/deploy the Spring Boot application.  

```
git clone https://github.com/spring-guides/gs-rest-service.git
```

You can either create a Procfile or update the Manifest.  The preferred approach is to update the manifest as shown below.   


This application will be deployed to CF's DEA architecture, so the meta-buildpack will not execute at this point and the service is directly available from `http://rest-service.bosh-lite.com/greeting`.  If you want the meta-buildpack to execute, then the application must be deployed to the Diego Architecture.  

### Update the manifest
Update the manifest file as shown below; the file is located in `gs-rest-service/complete`.  When the app starts, CF will assign `rest-service.bosh-lite.com` as the route to this service.  The `path` property tells CF where the application code is located.  The is also the directory where CF will run the buildpack detection process to determine which buildpack to apply to start the service.

```
---
applications:
- name: spring_hello
  memory: 256M
  instances: 1
  host: rest-service
  domain: bosh-lite.com
  path: build/libs/gs-rest-service-0.1.0.jar
  env:
    JBP_CONFIG_JAVA_MAIN: '{arguments: "--server.port=8090"}'
```

### Create a Procfile
Alternative approach to updating the manifest. Skip this step and use the Manifest approach above.  
```
cd gs-rest-service/complete

touch Procfile
```

Enter the following command into the Procfile.  
```
web: java -jar build/libs/gs-rest-service-0.1.0.jar --server.port=8090
```

## 11.a Configure a Service binding
https://docs.cloudfoundry.org/devguide/services/user-provided.html

The following command allows you to configure a [service](https://docs.cloudfoundry.org/devguide/services/user-provided.html) in CF to store the Microgateway configuration (org/env, org credentials) separate from the Spring application.

You must modify the service attributes below before you execute the `cf cups` command.
* org - Apigee organization
* env - Apigee environment
* user - Apigee Org Administrator username
* pass - Apigee Org Administrator password

### Create the new service
```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "tags": ["edgemicro"]}'
```

### Update an existing service
You only have to execute this command if you want to update an existing service.  
```
cf uups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "tags": ["edgemicro"]}'
```

### View all services/View existing service
```
cf services
cf service edgemicro_service
```

## 11.b Bind a Service to an App
You must bind the service to the spring_hello app so that the Edge Microgateway configuration values are available to Edge Microgateway_decorator during startup.  
```
cf bind-service spring_hello edgemicro_service
```

Result:

```
Binding service edgemicro_service to app spring_hello in org orgname / space myspace as admin...
OK
TIP: Use 'cf restage spring_hello' to ensure your env variable changes take effect
```

Display environment variables for application.  
```
cf env spring_hello
```
Result:
```
Getting env variables for app spring_hello in org orgname / space myspace as admin...
OK

System-Provided:
{
 "VCAP_SERVICES": {
  "user-provided": [
   {
    "credentials": {
     "application_name": "edgemicro_service"
    },
    "label": "user-provided",
    "name": "Edge Microgateway_service",
    "syslog_drain_url": "",
    "tags": [],
    "volume_mounts": []
   }
  ]
 }
}

{
 "VCAP_APPLICATION": {
  "application_id": "ec01ae73-7408-4154-9500-38a32a72c114",
  "application_name": "spring_hello",
  "application_uris": [
   "rest-service.bosh-lite.com"
  ],
  "application_version": "245df168-4620-4c03-9aac-94c5c139378c",
  "cf_api": "https://api.bosh-lite.com",
  "limits": {
   "disk": 1024,
   "fds": 16384,
   "mem": 256
  },
  "name": "spring_hello",
  "space_id": "1ee46a8b-5486-43f7-8b5b-c5a06d8ae4f2",
  "space_name": "myspace",
  "uris": [
   "rest-service.bosh-lite.com"
  ],
  "users": null,
  "version": "245df168-4620-4c03-9aac-94c5c139378c"
 }
}
```


## 12. Install Diego Enabler Plugin

### Deploy to diego-release CF 2nd Attempt - WORKS
This section discusses the second attempt to deploy the Diego architecture in CF. I followed the instructions listed here.
https://github.com/cloudfoundry/diego-design-notes/blob/master/migrating-to-diego.md

Install Diego enabler.
```
cf install-plugin Diego-Enabler -r CF-Community
```

#### Make sure to bind the Edge Microgateway Service to spring_hello app
```
cf bind-service spring_hello Edge Microgateway_service
```

### Deploy to diego-release CF 1st Attempt
This is recorded for posterity, so you can skip this section.  
This is the first attempt to deploy to Diego architecture, which was not successful.  Need to troubleshoot this approach.  
https://github.com/cloudfoundry/diego-release/blob/develop/docs/manifest-generation.md#example
The following command does not work. It generates and error (Need to troubleshoot).
```
cd [parent dir]/Github/diego-release

scripts/generate-deployment-manifest \
  -c ../bosh/gs-rest-service/complete/manifest.yml \
  -i manifest-generation/bosh-lite-stubs/iaas-settings.yml \
  -p manifest-generation/bosh-lite-stubs/property-overrides.yml \
  -n manifest-generation/bosh-lite-stubs/instance-count-overrides.yml \
 -v manifest-generation/bosh-lite-stubs/release-versions.yml \
 -s manifest-generation/bosh-lite-stubs/postgres/diego-sql.yml \
 -x \
 -d manifest-generation/bosh-lite-stubs/experimental/voldriver/drivers.yml \
 -b
```

This is the script from the documentation above.
```
cd [parent dir]/Github/diego-release

scripts/generate-deployment-manifest \
  -c [parent directory]/Github/bosh/gs-rest-service/complete/cf.yml \
  -i manifest-generation/bosh-lite-stubs/iaas-settings.yml \
  -p manifest-generation/bosh-lite-stubs/property-overrides.yml

```
The result will be a directory named `diego*` in `/tmp`
I took the `diego.yml` file from the `diego*` directory and I copied it to
the `[parent dir]/Github/bosh/gs-rest-service/complete` directory


I renamed the original `manifest.yml` file to `manifest_orig.yml` and I renamed the `diego.yml` to `manifest.yml`.
I had to make several changes to this file based on the errors reported. View the updated manifest.yml.
* copied the `manifest_orig.yml` into the `manifest.yml`
* removed several null references in the manifest.yml

Edgemicro v2.1.2
```
cf target -o "apigee" -s "myspace"

cf push spring_hello
```



## 13. Deploy to CF and enable Diego
Make sure your CF target is set (completed in step 7) and then push the spring_hello application.  At this point when you deploy to CF, the application is deployed to the DEA (Droplet Execution Agent) architecture.  Therefore, you must enable Diego for the app to run on the diego architecture.  If you don't enable it then the meta-buildpack does not get applied (need to troubleshoot why).

Edgemicro v2.1.2
```
cf target -o "orgname" -s "myspace"
cd [path to your Github directory]/Github/bosh/gs-rest-service/complete
cf push spring_hello --no-start
cf enable-diego spring_hello
cf start spring_hello
```

Edgemicro v2.3.1
```
cf target -o "orgname" -s "myspace"
cd [path to your Github directory]/Github/bosh/gs-rest-service/complete
cf push spring_hello --no-start -m 512MB
cf enable-diego spring_hello
cf start spring_hello
```

Overview of process execution when you execute the `cf start spring_hello` command.
* CF starts a staging container to build the droplet (container that runs the app).
* Meta-buildback executes first
* It passes control to the buildpacks process to detect which buildpack should execute the app.
* The appropriate buildback executes, in this case Java.
* Control is passed back to meta-buildpack
* Meta-buildpack calls each decorator's decorate script. In this case it calls the Edge Microgateway-decorator.
* The decorator's detect script determines if it should the decorator's compile step.
* The Edge Microgateway-decorator executes the compile script, which in turn initializes and configures Edge Microgateway. It also copies a shell script into the `profile.d` directory which executes when the container starts.  The shell script starts Edge Microgateway and listens on port 8080.
* Droplet is saved in the CF blob store.
* Staging container is destroyed.
* CF creates a new container which starts Edge Microgateway and then starts the Spring application.

## 13.b View the status of the app
```
cf app spring_hello
```

## 14. Test Service
If you copy the URL into your browser you should receive an error from Edge Microgateway stating that you are missing the authorization header.  

Paste the link below in your browser.
```
http://rest-service.bosh-lite.com/greeting
```
OR
```
curl http://rest-service.bosh-lite.com/greeting
```

## 15. Edge Microgateway Test
In order to send a valid request, you must obtain a valid access token first.

### a. Request JWT
Request a JWT from your OAuth proxy deployed to Edge.  This OAuth proxy is configured automatically when the Edge Microgateway-decorator executes the `init` step.  Make sure to include the client_id and secret from your Apigee product in the curl command below.
```
curl -X POST -H "Content-type: application/json" http://org-env.apigee.net/edgemicro-auth/token -d '{"client_id":"client_id","client_secret":"client_secret","grant_type":"client_credentials"}' -v
```

Mocked Response (actual JWT is much longer):
```
{ token: 'qOoFoQ4hFQ' }
```

### b. Send the request with Authorization Bearer token header
```
curl -X GET \
-H "Authorization: Bearer qOoFoQ4hFQ" \
http://rest-service.bosh-lite.com/greeting/ -v
```

# Scale Up/Down
## Scale Up
Scale the number of instances up by entering the `-i` command.  The cloud controller listens for scaling requests and passes that to the BBS (Bulletin Board System), which forwards the request to the Diego Brain, which auctions the jobs to Cells.  The Diego Brain monitors actual LRPs (Long Running Processes) vs the desired LRPs and maintains consistency between the two.

Execute the following command to scale the number of instances up.
```
cf scale spring_hello -i 3
```

Then execute the following command to see that the CF completed the request.
```
cf app spring_hello
```

The result will display the number of running instances.  
```
Showing health and status for app spring_hello in org apigee / space myspace as admin...
OK

requested state: started
instances: 3/3
usage: 256M x 3 instances
urls: rest-service.bosh-lite.com
last uploaded: Fri Dec 2 22:35:21 UTC 2016
stack: cflinuxfs2
buildpack: java-buildpack=v3.10-https://github.com/cloudfoundry/java-buildpack.git#193d6b7 java-main open-jdk-like-jre=1.8.0_111 open-jdk-like-memory-calculator=2.0.2_RELEASE spr... (with decorator Edge Microgateway-decorator DECORATE called!
detect called
Edge Microgateway-config)

     state     since                    cpu    memory      disk      details
#0   running   2016-12-02 04:36:50 PM   0.0%   0 of 256M   0 of 1G
#1   running   2016-12-06 08:16:34 AM   0.0%   0 of 256M   0 of 1G
#2   running   2016-12-06 08:16:38 AM   0.0%   0 of 256M   0 of 1G
```

## Scale Down
Scale down the number of instances by executing the command below.

```
cf scale spring_hello -i 1
```

Execute the `cf app` command to see the number of instances reduced back to 1.
```
cf app spring_hello
```

### SSH into an instance
SSH into a running CF container by including the container index number with the `-i` parameter.
```
cf ssh spring_hello -i 1
```

# Testing
This decorator was tested with a sample Spring Boot application.

* Additional tests will be added for Node.js, Java, etc.

## Gatling tests
[Gatling](http://gatling.io/) tests are included in the `gatling` directory.  

The screen shot below is a partial view of the Gatling tests against a Bosh-lite instance running Cloud Foundry Diego architecture with a single container running Edge Microgateway and a Spring Boot Application.  

* one concurrent user for 30 seconds at a constant rate
![Performance Test Results](/gatling/screenshots/gatlingtestresults.png?raw=true "Gatling Test Results")


### How to execute the Gatling tests?
1. Must have an Edge account with an Edge product defined (see prerequisites above)
2. Must update the following variables in the `gatling/src/test/edgemicro/BasicSimulation.scala` class. Update the values shown below.
   * val org = "edge_org"
   * val env = "edge_env"
   * val clientId = "clientId"
   * val secret = "clientsecret"
3. Execute the following command.
```
cd gatling
mvn gatling:execute -Dgatling.simulationClass=edgemicro.BasicSimulation
```

# MISC

## Troubleshooting - If spring_hello does not work, then follow the steps below to delete/recreate it

### 1. Delete spring_hello
```
cf delete spring_hello
```

### 2. Redeploy to CF
```
cf push spring_hello
```

```
cf apps
```

Should display

Edgemicro 2.1.2
```
name           requested state   instances   memory   disk   urls
spring_hello   started           1/1         256M     1G     rest-service.bosh-lite.com
```

Edgemicro v2.3.1
```
name           requested state   instances   memory   disk   urls
spring_hello   started           1/1         512M     1G     rest-service.bosh-lite.com
```

### 3. Deploy to CF Diego Architecture
```
cf enable-diego spring_hello
```

### 4. Bind the service
Make sure that it was [created](#create-the-new-service).
```
cf bind-service spring_hello Edge Microgateway_service
```

### 5. Restage Spring hello
```
cf restage spring_hello
```

## Tracing a cf push
```
CF_TRACE=true cf push spring_hello
```

## SSH into Cloud Foundry containers as a root user
https://discuss.pivotal.io/hc/en-us/articles/220866207-How-to-login-an-app-s-container-as-root-

## Cloud Foundry Logs and Events

### logs
Stream events to terminal.
```
cf logs spring_hello
```

Export the most recent log events to the terminal.
```
cf logs spring_hello --recent
```

You may receive the following error when you execute it. It may take a few minutes before the logs are streamed; just keep executing it.  
```
FAILED
Timed out waiting for connection to Loggregator (wss://doppler.bosh-lite.com:4443).
```

### Events
```
cf events spring_hello
```

## Tile buildpacks - Need to review
This is not necessary but can be used as an added benefit
https://github.com/cf-platform-eng/tile-generator


This gets you access to the root user.
```
sudo su -
```

## Deploy Apps With Custom Buildpack
https://docs.cloudfoundry.org/buildpacks/custom.html#deploying-with-custom-buildpacks

```
cf push my-new-app -b git://github.com/johndoe/my-buildpack.git
```

## Deploy Custom Buildpack to bosh-lite with CF
https://docs.cloudfoundry.org/buildpacks/custom.html


Execute the following line:
```
./upload
```

# Immediate Action Items
1. Document additional space requirements for including Edge Microgateway in CF App container.
2. Document latency between first POC (EM running in separate containers) vs EM running in same container.    

# Open Items
1. Current implementation uses Microgateway v2.1.2; however, 3.2.1 has just been released, so I need to switch to this version.  
2. Need to change the code so that you can configure which version of Edge Microgateway you want to use; however, the default selection should be the most current Edge Microgateway.
3. Clean up the configure script.
