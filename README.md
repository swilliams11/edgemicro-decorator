# Apigee Edge Microgateway Decorator

This is a [decorator](https://github.com/guidowb/meta-buildpack/blob/master/README.md#decorators) buildpack for Cloud Foundry that provides integration with the Apigee Edge API Management via the Edge Microgateway.

When this decorator and the [meta-buildpack](https://github.com/guidowb/meta-buildpack))
is present in your Cloud Foundry deployment, you can select the 'Microgateway' service plan from the Apigee Edge service broker. With that service plan you can automatically add Apigee API Management via the Microgateway.

# Prerequisites
1. You should have an Apigee Edge account (private or public).
2. You should [create an Apigee Edgemicro](http://docs.apigee.com/microgateway/latest/setting-and-configuring-edge-microgateway#Part2) aware proxy.
   a) Proxy base path should be /greeting
   b) Target should be http://localhost:8090/greeting
   c) You should configure the following paths in your Apigee Edgemicro product: `/greeting`, `/greeting/**`.
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
Step 7 in the above link prompts you to select between MySQL and Postgres.  I tried the MySQL option but that generated an error so I decided to use the Postgres option instead.  Need to go back and determine why this option did not work. I think it might require the use of another Github.  


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

List all orgs
```
cf orgs
```


## 8. Upload meta-buildpack
You must upload the meta-buildpack to CF for this to work.
https://github.com/cf-platform-eng/meta-buildpacks

```
git clone https://github.com/cf-platform-eng/meta-buildpack.git
cd meta-buildpack
./build
./upload
```


To view the buildpacks that are loaded in CF.
```
cf buildpacks
```

## 9. Clone a Sample Spring Boot application
This is a sample Spring Boot application that I used to test the edgemicro-decorator. Follow the instructions listed in the Github README file to build/deploy the application.  

```
git clone https://github.com/spring-guides/gs-rest-service.git
```

You can either create a Procfile or update the Manifest.  The preferred approach is to update the manifest as shown below.   


This application will be deployed to CF DEA architecture, so the meta-buildpack will not execute at this point and the service is directly available from `http://rest-service.bosh-lite.com/greeting`.

### Update the manifest
Update the manifest file as shown below.  When the app starts, CF will assign `rest-service.bosh-lite.com` as the route to this service.  The `path` property tells CF where the application code is located.  The is also the directory where CF will run the buildpack detection process to determine which buildpack to apply to start the service.

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
Alternative approach to updating the manifest.
```
cd gs-rest-service/complete

touch Procfile
```

Enter the following command into the Procfile.  
```
web: java -jar build/libs/gs-rest-service-0.1.0.jar --server.port=8090
```

## 10.a Configure a Service binding
https://docs.cloudfoundry.org/devguide/services/user-provided.html

The following command allows you to configure a [service](https://docs.cloudfoundry.org/devguide/services/user-provided.html) in CF to store the Microgateway configuration (org/env, org credentials) separate from the Spring application.

You must modify the service attributes below before you execute it.
* org - Apigee organization
* env - Apigee environment
* user - Apigee Org Administrator username
* pass - Apigee Org Administrator password

### Create the new service
```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "tags": ["edgemicro"]}'
```

### Update an existing service
You only have to execute this command if you want to update an existing service.  
```
cf uups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "tags": ["edgemicro"]}'
```

### View all services/View existing service
```
cf services
cf service edgemicro_service
```

## 10.b Bind a Service to an App
You must bind the service to the spring_hello app so that the Edgemicro configuration values are available to edgemicro_decorator during startup.  
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
    "name": "edgemicro_service",
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


## 11. Install Diego in CF

### Deploy to diego-release CF 2nd Attempt - WORKS
This section discusses the second attempt to deploy to Diego architecture. I followed the instructions listed here.
https://github.com/cloudfoundry/diego-design-notes/blob/master/migrating-to-diego.md

Install Diego enabler.
```
cf install-plugin Diego-Enabler -r CF-Community
```

#### Make sure to bind the Edgemicro Service to spring_hello app
```
cf bind-service spring_hello edgemicro_service
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

```
cf target -o "apigee" -s "myspace"

cf push spring_hello
```

## 12. Deploy to CF and enable Diego
Make sure your CF target is set and then push the spring_hello application.  At this point when you deploy to CF, the application is deployed to the DEA architecture.  Therefore, you must enable diego for the app for the app to run on the diego architecture.  If you don't enable it then the meta-buildpack does not get applied (need to troubleshoot why).

```
cf target -o "orgname" -s "myspace"
cd [path to your Github directory]/Github/bosh/gs-rest-service/complete
cf push spring_hello --no-start
cf enable-diego spring_hello
cf start spring_hello
```

Overview of process execution when you execute the `cf start spring_hello` command.
* CF starts a staging container to build the droplet (container execution).
* Meta-buildback executes first
* It passes control to the buildpacks to detect which buildpack should execute.
* The appropriate buildback executes, in this case Java.
* Control is passed back to meta-buildpack
* Meta-buildpack calls each decorator's detect script. In this case it calls the edgemicor-decorator.
* The decorator's detect script determines if decorator will execute it's compile step.
* The edgemicor-decorator executes the compile script, which in turns initializes and configures microgateway. It also copies a shell script into the `profile.d` directory which executes when the container starts.  The shell script starts Microgateway and listens on port 8080.
* Droplet is saved in the blob store.
* Staging container is destroyed.
* CF creates a new container which starts Edgemicro and then starts the Spring application.

## 13.b View the status of the app
```
cf app spring_hello
```

## 14. Test Service
If you copy the URL into your browser you should receive an error from the Microgateway stating that you are missing the authorization header.  
```
http://rest-service.bosh-lite.com/greeting
```
OR
```
curl http://rest-service.bosh-lite.com/greeting
```

## 15. Edgemicro Test
In order to send a valid request, you must obtain a valid access token first.

### a. Request JWT
Request an JWT from your OAuth proxy deployed to Edge.  Make sure to include the client_id and secret from your Apigee product.
```
curl -X POST -H "Content-type: application/json" http://org-env.apigee.net/edgemicro-auth/token -d '{"client_id":"client_id","client_secret":"client_secret","grant_type":"client_credentials"}' -v
```

Response:
```
{ token: 'qOoFoQ4hFQ' }
```

### b. Send the request with Authorization Bearer token header
```
curl -X GET \
-H "Authorization: Bearer qOoFoQ4hFQ" \
http://rest-service.bosh-lite.com/greeting -v
```

# Troubleshooting - If spring_hello does not work, then follow the steps below to delete/recreate it

## 1. Delete spring_hello
```
cf delete spring_hello
```

## 2. Redeploy to CF
```
cf push spring_hello
```

```
cf apps
```

Should display

```
name           requested state   instances   memory   disk   urls
spring_hello   started           1/1         256M     1G     rest-service.bosh-lite.com
```

## 3. Deploy to CF Diego
```
cf enable-diego spring_hello
```

## 4. Bind the service - Make sure it is created first (see above).
```
cf bind-service spring_hello edgemicro_service
```

## 5. Restage Spring hello
```
cf restage spring_hello
```

# Tracing a cf push
```
CF_TRACE=true cf push spring_hello
```

# SSH into Cloud Foundry containers as a root user
https://discuss.pivotal.io/hc/en-us/articles/220866207-How-to-login-an-app-s-container-as-root-

# Cloud Foundry Logs and Events

## logs
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

## Events
```
cf events spring_hello
```

# Tile buildpacks - Need to review
This is not necessary but can be used as an added benefit
https://github.com/cf-platform-eng/tile-generator


This gets you access to the root user.
```
sudo su -
```

# Deploy Apps With Custom Buildpack
https://docs.cloudfoundry.org/buildpacks/custom.html#deploying-with-custom-buildpacks

```
cf push my-new-app -b git://github.com/johndoe/my-buildpack.git
```

# Deploy Bosh Buildpack to bosh-lite with CF
https://docs.cloudfoundry.org/buildpacks/custom.html


Execute the following line:
```
./upload
```

# Open Items
1. Current implementation uses Microgateway v2.1.2; however, 3.1.1 has just been released, so I need to switch to this version.  
2. Need to change the code so that you can configure which version of Microgateway you want to use; however, the default selection should be the most current Microgateway.
3. Clean up the configure script.
