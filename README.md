# Apigee Edge Microgateway Decorator

## This is not an official Google product

## Official Edge Microgateway Decorator
The Edge Microgateway Decorator is now included in the Apigee Service Broker as the coresident plan. Please use this link instead.
https://docs.apigee.com/api-platform/integrations/cloud-foundry/proxying-cloud-foundry-app-microgateway-coresident-plan

This is a [decorator](https://github.com/guidowb/meta-buildpack/blob/master/README.md#decorators) buildpack for Cloud Foundry that supports integration with Edge on-premises/public cloud via the Edge Microgateway.

When this decorator and the [meta-buildpack](https://github.com/guidowb/meta-buildpack)
is present in your Cloud Foundry deployment, you can select the 'Microgateway' service plan from the Apigee Edge service broker. With that service plan you can automatically add Apigee API Management via the Microgateway.

Try the [README-SHORT.md](https://github.com/swilliams11/edgemicro-decorator/blob/master/README-SHORT.md) version instead.

# TOC
* [Summary](#summary)
* [Support](#support)
* [PCF Dev](#pcf-dev)
* [Prerequisites](#prerequisites)
* [Select Node.js Version](#select-nodejs-version)
* [Configuration steps](#what-you-need-to-know)
  1. [Deploy CF](#1-deploying-cloud-foundry)
  2. [Install Go](#2-install-go)
  3. [Install Spiff](#3-install-spiff)
  4. [Deploy Cloud Foundry](#4-deploy-cloud-foundry)
  5. [Add Routes](#5-add-routes)
  6. [Setup CF API](#6-setup-the-cf-api)
  7. [Login to CF API](#7-login-to-the-api)
  8. [Upload Edgemicro Decorator](#8-upload-edgemicro-decorator)
  9. [Upload meta-buildpack](#9-upload-meta-buildpack)
  10. [Clone Sample Spring Boot Application](#10-clone-a-sample-spring-boot-application)
  11. [Configure the service binding](#11-configure-a-service-binding)
      * [Create a New Service](#create-the-new-service)
      * [Update an Existing Service](#update-an-existing-service)
      * [Enable Spike Arrest](#enable-spike-arrest)
      * [Enable On-premises Deployment](#enable-on-premises-deployment)
      * [Disable OAuth plugin](#disable-oauth-plugin)
      * [Enable Custom Plugins](#enable-custom-plugins)
      * [Enable Quota](#enable-quota)
      * [Select Node.js Version](#select-nodejs-version-1)
      * [Include org-env-config.yaml](#include-a-org-env-configyaml-file)
      * [View All Services or an Existing Service](#view-all-servicesview-existing-service)
  12. [Bind Service to App](#12-bind-a-service-to-an-app)
  13. [Install Diego enabler Plugin](#13-install-diego-enabler-plugin)
  14. [Deploy and Enable Diego](#14-deploy-to-cf-and-enable-diego)
  15. [View the App Status](#15-view-the-status-of-the-app)
  16. [Test the Service](#16-test-service)
  17. [Edge Microgateway Test](#17-edge-microgateway-test)
* [Scale Cloud Foundry app up or down](#scale-updown)
* [Testing](#testing)
* [Miscellaneous](#misc)

# Summary
The reason we developed an [Edge Microgateway](http://docs.apigee.com/microgateway/latest/overview-edge-microgateway) decorator is to allow customers running Cloud Foundry to protect their microservices with Apigee Edge, which supports OAuth 2.0, rate limiting with spike arrests and quotas, and analytics to monitor your run-time traffic.  The Edge Microgateway decorator will run inside the same container that executes the App, which significantly reduces the latency.  The following documentation describes how to test this decorator in a Bosh-lite instance protecting a sample Spring Boot application.

Please note the following:
* Edge Microgateway is listening on port 8080
* [Spring Boot sample application](https://github.com/spring-guides/gs-rest-service) is listening on port 8090 and you can view the [docs here](https://spring.io/guides/gs/rest-service/).
* Cloud Foundry creates an HTTP route to the app based on the Manifest.yml file located in the spring_hello App
* Apps that use the HTTP route are required to listen on port 8080
* This repo uses Edge Microgateway version 2.3.1

## Updates
* July 18, 2017
The edgemicro-decorator installs `edgemicro` with `npm install edgemicro@VERSION -g`.  The version is supplied in the `edgemicro_version` property in the user defined service instance (i.e. `"edgemicro_version":"2.4.6"`). Now you can install any version of Edge Microgateway with the edgemicro-decorator.  However, we recommend that you use the most current version. (as of July 18, 2017 it is 2.4.6).

If you attempt to install an invalid edgemicro version then you should receive an error similar to the one below; Cloud Foundry will not start the container.
```
npm ERR! Linux 4.2.0-42-generic
npm ERR! argv "/tmp/app/node/bin/node" "/tmp/app/node/bin/npm" "install" "edgemicro@2.5.7" "-g"
npm ERR! node v6.10.2
npm ERR! npm  v3.10.10
npm ERR! code ETARGET
npm ERR! notarget No compatible version found: edgemicro@2.5.7
npm ERR! notarget Valid install targets:
npm ERR! notarget 3.0.4-early-access, 3.0.3-early-access, 3.0.1-early-access, 3.0.0-early-access, 2.4.6, 2.4.6-beta, 2.4.5-beta, 2.4.4-beta, 2.4.3-beta, 2.4.2-beta, 2.4.1-beta, 2.4.0-beta, 2.3.5, 2.3.3, 2.3.3-beta, 2.3.2-beta, 2.3.1, 2.3.0-beta, 2.2.5-beta, 2.2.4-beta, 2.2.3-beta, 2.2.2-beta, 2.1.2, 2.1.1, 2.1.0, 2.1.0-beta.2, 2.1.0-beta, 2.0.12, 2.0.11, 2.0.11-beta.3, 2.0.11-beta.2, 2.0.11-beta, 2.0.10, 2.0.9, 2.0.8, 2.0.7, 2.0.6, 2.0.5, 2.0.4, 2.0.0, 0.0.0
npm ERR! notarget
npm ERR! notarget This is most likely not a problem with npm itself.
npm ERR! notarget In most cases you or one of your dependencies are requesting
npm ERR! notarget a package version that doesn't exist.
npm ERR! Please include the following file with any support request:
npm ERR!     /home/vcap/npm-debug.log
/tmp/buildpacks/a846680436e1e5886816e8118ca5c6d2/bin/compile: line 189: edgemicro: command not found
IS_ONPREMISES is false
configure cloud...
/tmp/buildpacks/a846680436e1e5886816e8118ca5c6d2/bin/compile: line 95: edgemicro: command not found
edgemicro configure failed.
[meta-buildpack] Passing on exit code  1
Failed to compile droplet
Exit status 223
Staging failed: Exited with status 223
Destroying container
Successfully destroyed container
```

## Can I create multiple edgemicro Cloud Foundry service instances within the same Cloud Foundry org and space bound to separate Cloud Foundry Apps?
Yes.

You can create two service instances within a Cloud Foundry org/space (the service names have to be unique). In my CF environment I created one service instance to connect to my private Apigee installation and second instance to connect to my public Apigee cloud instance.  Then I created a binding between `spring_hello` and `edgemicro_service` and another binding between `spring_hello_2` and `edgemicro_service_public`.  

```
name                       service         plan   bound apps       last operation
edgemicro_service          user-provided          spring_hello
edgemicro_service_public   user-provided          spring_hello_2
```

This effectively means that you can have dev, test, preprod and prod CF user-defined service instances within the same Cloud Foundry org and space.  You could also control one set of microgateway instances with API Key validation only and another set of microgateway instances with OAuth 2 token validation (JWTs).  

## What if I want some Cloud Foundry apps to be protected by Edge Microgateway and the other apps to be unprotected?
If you don't bind an Cloud Foundry app to the `edgemicro_service`, then the edgemicro-decorator will not execute for that app.  

## What is the additional space required for my container?
Edge Microgateway is a Node.js application that includes other node libraries as well. Therefore, the total additional space required is the total space for the Node.js runtime, the core Microgateway and all of the required node modules.  
* Node.js v6.9.1-linux-x64 - ~48MB
* Edge Microgateway v2.1.2 (including node_modules) - ~103MB
* Edge Microgateway v2.3.1 (including node_modules) - ~103MB

## What files are included in the edgemicro-decorator?
There are several files that are included:
* `lib` directory
  * microgateway-2.1.2.zip - includes all the required node_modules for Microgateway to run
  * microgateway-2.3.1.zip - includes all the required node_modules for Microgateway to run
  * microgateway-2.1.2min.zip - only includes the core Microgateway.  This requires that `npm install` is executed to install the required node modules.
  * node-v6.9.1-linux-x64.tar.xz - Node.js runtime
  * nodejs.sh - copied to `profile.d` directory during the compile phase; sets environment variables
  * zz_micro_config.sh - copied to `profile.d` directory; it sets environment variables and starts Microgateway before CF starts the actual application.  
  * `plugins` folder that includes two sample custom plugins to demonstrate how to include custom plugins with the decorator. See the [enable custom plugins section](#enable-custom-plugins) for more details.
* `bin` directory
  * compile - script that installs Node.js, and Microgateway; initializes and configures Microgateway.
  * decorate - determines if this decorator should run
  * detect - always returns false
* `upload` - uploads this decorator to CF
* `edge` directory - includes the `edgemicro_cloudfoundry` proxy and scripts to deploy it along with the required product, app and developer to Edge.
* `gatling` directory - includes Gatling tests for the Edgemicro/Spring boot application deployed to Cloud Foundry.

## What is the additional latency to proxy requests via Microgateway running on the same VM as my app?
* See the [Gatling tests](#gatling-tests) below

## How much memory is required to run Edgemicro in my container?
When I ran EM v2.1.2 in CF Diego architecture it was able to run within a 256MB container.  However, when I switched to EM 2.3.1, the container failed on startup and there were out-of-memory error messages.  I increased the container memory to 512MB and then the container started successfully.  

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

# Support
For support on the Edgemicro-decorator, please create an issue directly against this repository.  Please do not submit a support ticket with Apigee because they are not supporting this product.  We are currently in the process of transferring this project to our engineering team and updating the developer experience.

# PCF Dev
If you want to quickly setup a Cloud Foundry environment on your local machine, then you
can use [PCF Dev](https://pivotal.io/pcf-dev) instead. Follow the steps [here](https://pivotal.io/platform/pcf-tutorials/getting-started-with-pivotal-cloud-foundry-dev/introduction).  Once you complete the steps in that tutorial then you can continue with [step 8](#8-upload-edgemicro-decorator) below. Keep in mind that the domain for PCF Dev is different than the one below, so be sure to change the domain names in the examples accordingly.

# Prerequisites
1. You should have an Apigee Edge account (on-premises or public).
2. You should [create an Apigee Edge Microgateway](http://docs.apigee.com/microgateway/latest/setting-and-configuring-edge-microgateway#Part2) aware proxy.  Follow the [README](https://github.com/swilliams11/edgemicro-decorator/tree/master/edge) in the `edge` directory which describes how to deploy the Edge Microgateway aware proxy.  The scripts in this directory will correctly configure the items listed below.  
   * Proxy base path should be /greeting
   * Target should be http://localhost:8090/greeting
   * You should configure the following paths in your Apigee Edge Microgateway product: `/**`, `/greeting`, `/greeting/**`.
3. You should install [Bosh-lite](https://github.com/cloudfoundry/bosh-lite).

# Select Node.js Version
This latest commit allows you to select the Node.js version, however, you must include the `tar.xz` file in the `lib` directory and you also must include the version in the `edgemicro` service. [See below](#select-nodejs-version-1) for details.

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
Update the manifest file as shown below; the file is located in `gs-rest-service/complete`.  When the app starts, CF will assign `rest-service.bosh-lite.com` as the route to this service.  The `path` property tells CF where the application code is located.  This is also the directory where CF will run the buildpack detection process to determine which buildpack to apply to start the service.

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

## 11 Configure a Service binding
https://docs.cloudfoundry.org/devguide/services/user-provided.html

The following command allows you to configure a [service](https://docs.cloudfoundry.org/devguide/services/user-provided.html) in CF to store the Microgateway configuration (org/env, org credentials) separate from the Spring application.

You must modify the service attributes below before you execute the `cf cups` command.
* org - Apigee organization
* env - Apigee environment
* user - Apigee Org Administrator username
* pass - Apigee Org Administrator password

### TOC
* [Create a New Service](#create-the-new-service)
* [Update an Existing Service](#update-an-existing-service)
* [Enable Spike Arrest](#enable-spike-arrest)
* [Enable On-premises Deployment](#enable-on-premises-deployment)
* [Disable OAuth plugin](#disable-oauth-plugin)
* [Enable Custom Plugins](#enable-custom-plugins)
* [Enable Quota](#enable-quota)
* [Select Node.js Version](#select-nodejs-version-1)
* [Include org-env-config.yaml](#include-a-org-env-configyaml-file)
* [View All Services or an Existing Service](#view-all-servicesview-existing-service)

### Create the new service
```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "nodejs_version_number": "6.10.2", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "tags": ["edgemicro"]}'
```

### Update an existing service
You only have to execute this command if you want to update an existing service.  
```
cf uups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "nodejs_version_number": "6.10.2", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "tags": ["edgemicro"]}'
```

### Enable Spike Arrest
Spike arrest will always be added after the `oauth` plugin in the `plugin sequence` section.

#### Spike Arrest without buffersize

The default `buffersize` is zero.

```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "nodejs_version_number": "6.10.2", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "enable_spike_arrest": "true", "spike_arrest_config" : {"timeunit": "minute", "allow" : "30"}, "tags": ["edgemicro"]}'
```

#### Spike Arrest with buffersize
The `buffersize` is set.
```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "nodejs_version_number": "6.10.2", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "enable_spike_arrest": "true", "spike_arrest_config" : {"timeunit": "minute", "allow" : "30", "buffersize": "100"}, "tags": ["edgemicro"]}'
```

 View the [spike arrest plugin documentation](http://docs.apigee.com/microgateway/latest/use-plugins#usingthespikearrestplugin) for more details regarding configuration options.

### Enable On-premises Deployment
Enable on-premises configuration option with the following command.
* virtual_host is a comma separated list of virtual hosts within your Edge environment. (i.e "default,secure")

```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "nodejs_version_number": "6.10.2", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "onpremises": "true", "onprem_config" : {"runtime_url": "http://192.168.56.101:9001", "mgmt_url" : "http://192.168.56.101:8080", "virtual_host" : "default"}, "tags": ["edgemicro"]}'
```

View the [on premises documentation](http://docs.apigee.com/microgateway/latest/setting-and-configuring-edge-microgateway#part1configureedgemicrogateway-apigeeprivatecloudconfigurationsteps) for more details regarding configuration options.

#### Update the Cloud Foundry Staging Security Group(s)
You must update the CF Staging security group as shown below.  

* List all the security groups available.
```
cf security-groups
```

* List the security groups that are applicable to staging containers.
```
cf staging-security-groups
```
RESPONSE:
```
public_networks
dns
```

* Get the public_networks security group IPs.
```
cf security-group public_networks
```
RESPONSE:
```javascript
[
		{
			"destination": "0.0.0.0-9.255.255.255",
			"protocol": "all"
		},
		{
			"destination": "11.0.0.0-169.253.255.255",
			"protocol": "all"
		},
		{
			"destination": "169.255.0.0-172.15.255.255",
			"protocol": "all"
		},
		{
			"destination": "172.32.0.0-192.167.255.255",
			"protocol": "all"
		},
		{
			"destination": "192.169.0.0-255.255.255.255",
			"protocol": "all"
		}
	]
```

* Copy this into a JSON file named `public_networks.json` and add the IP address of your on-premise deployment, as shown below. **NOTE this is for Non production CF installations.**
```javascript
[
		{
			"destination": "0.0.0.0-9.255.255.255",
			"protocol": "all"
		},
		{
			"destination": "11.0.0.0-169.253.255.255",
			"protocol": "all"
		},
		{
			"destination": "169.255.0.0-172.15.255.255",
			"protocol": "all"
		},
		{
			"destination": "172.32.0.0-192.167.255.255",
			"protocol": "all"
		},
		{
			"destination": "192.168.0.0-255.255.255.255",
			"protocol": "all"
		},
    {
			"destination": "192.168.56.101",
			"protocol": "all"
		}
	]
```

 * Update the security group as shown below.
 ```
 cf update-security-group public_networks public_networks.json
 ```

 * Complete the same process outlined above for `services`, `user_bosh_deployments`, and `load_balancer`.

 * Once the security group is updated, then you must restage the app for it to pick up the changes.
 ```
 cf restage spring_hello
 ```

#### Testing Performed with local On-premises installation
Follow the steps above to ensure that CF can access the IP of your local installation.

### Disable OAuth Plugin
The current approach to disable the OAuth plugin is by setting the following properties:
* `enable_custom_plugins` is set to `true`
* `plugins` is set `analytics`.

Notice that `oauth` is **NOT** included in the `plugins` attribute.

**Please note that disabling the OAuth plugin will allow all requests to your Edge Microgateway.**

```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "nodejs_version_number": "6.10.2", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "enable_custom_plugins":"true","plugins":"analytics", "tags": ["edgemicro"]}'
```

### Enable Custom Plugins
The following items must be completed for this to work correctly.
* add the custom plugin to the `lib/plugins` folder.  
  * two sample plugins are included there by default as an example.
  * plugin folder name should match the plugin name in the `plugins` property.
* In the `edgemicro_service`
  * `enable_custom_plugins` should be set to `true`
  * `plugins` property should list all the plugins in the order in which you want them applied.
    * `plugins` property should be comma separated without any spaces


#### With OAuth
Enable the custom plugins by including `enable_custom_plugins` and `plugins` properties.
* Notice that `oauth` is included and it must be there.

```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "nodejs_version_number": "6.10.2", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "enable_custom_plugins":"true","plugins":"oauth,plugin1,plugin2", "tags": ["edgemicro"]}'
```

#### With OAuth and Spike Arrest
Enable the custom plugins by including `enable_custom_plugins` and `plugins` properties.
* Notice that `oauth` and `spikearrest` are included and they both must be there for this to work correctly.

```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "nodejs_version_number": "6.10.2", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "enable_custom_plugins":"true","plugins":"oauth,spikearrest,plugin1,plugin2", "enable_spike_arrest": "true", "spike_arrest_config" : {"timeunit": "minute", "allow" : "30"}, "tags": ["edgemicro"]}'
```

### Enable Quota
Enable the quota plugin by including `enable_quota` property set to `true`.
* Quota will be place after the OAuth plugin.

```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "nodejs_version_number": "6.10.2", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "enable_quota":"true", "tags": ["edgemicro"]}'
```

##### Enable Quota and Spike Arrest
Enable the quota plugin by including `enable_quota` property set to `true`.
* Quota will always be placed after the spike arrest.  

```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "nodejs_version_number": "6.10.2", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "enable_quota":"true", "enable_spike_arrest": "true", "spike_arrest_config" : {"timeunit": "minute", "allow" : "30"}, "tags": ["edgemicro"]}'
```

### Select Node.js Version - Decorator Installs Node
Use this property to download Node.js from the Nodejs.org site.  Select the Node.js version as shown below.  
Make sure that Node.js version number is specified in the `nodejs_version_number` property.
**NOTE: You can either enter this property or nodejs_version**

```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "edgemicro_version":"2.3.1", "edgemicro_port":"8080","nodejs_version_number": "6.10.2", "tags": ["edgemicro"]}'
```

### Select Node.js Version
**NOTE: Use the preferred approach above, since it will install Node.js for you. If you use the property below, then you must
include the `tar.xz` file in the `lib` directory of the edgemicro-decorator.**

Select the Node.js version as shown below.  Make sure that Node.js `tar.xz` file specified in the `nodejs_version` is also included in the `lib` directory.

```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "edgemicro_version":"2.3.1", "edgemicro_port":"8080","nodejs_version": "node-v6.9.1-linux-x64.tar.xz", "tags": ["edgemicro"]}'
```

### Include a org-env-config.yaml file
If your deployment request more custom configurations, then it may be easier to just include the `default.yaml` directly.

* if you include custom plugins in the `plugins` directory they will be copied over to the container.

Include the following properties as shown below.
```
"yaml_included":"true",
"yaml_name":"demo-test-config.yaml"
```

Example command shown below.
```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "nodejs_version_number": "6.10.2", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "yaml_included":"true", "yaml_name":"demo-test-config.yaml", "tags": ["edgemicro"]}'
```

### View all services/View existing service
```
cf services
cf service edgemicro_service
```

## 12 Bind a Service to an App
You must bind the service to the spring_hello app so that the Edge Microgateway configuration values are available to Edge Microgateway_decorator during startup.  
```
cf push --no-start
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
```javascript

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


## 13. Install Diego Enabler Plugin

### Deploy to diego-release CF 2nd Attempt - WORKS
This section discusses the second attempt to deploy the Diego architecture in CF. I followed the instructions listed here.
https://github.com/cloudfoundry/diego-design-notes/blob/master/migrating-to-diego.md

Install Diego enabler.
```
cf install-plugin Diego-Enabler -r CF-Community
```

#### Make sure to bind the Edge Microgateway Service to spring_hello app
```
cf bind-service spring_hello edgemicro_service
```

### Deploy to diego-release CF 1st Attempt
**This is recorded for posterity, so you can skip this section.**
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



## 14. Deploy to CF and enable Diego
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
* Meta-buildpack calls each decorator's decorate script. In this case it calls the edgemicro-decorator.
* The decorator's detect script determines if it should execute the decorator's compile step.
* Edgemicro-decorator executes the compile script, which in turn initializes and configures Edge Microgateway. It also copies a shell script into the `profile.d` directory, which executes when the container starts.  The shell script starts Edge Microgateway and listens on port 8080.
* Droplet is saved in the CF blob store.
* Staging container is destroyed.
* CF creates a new container which starts Edge Microgateway and then starts the Spring application.

## 15. View the status of the app
```
cf app spring_hello
```

## 16. Test Service
If you copy the URL into your browser you should receive an error from Edge Microgateway stating that you are missing the authorization header.  

Paste the link below in your browser.
```
http://rest-service.bosh-lite.com/edgemicro_hello/greeting
```
OR
```
curl http://rest-service.bosh-lite.com/edgemicro_hello/greeting
```

## 17. Edge Microgateway Test
In order to send a valid request, you must obtain a valid access token first.

### a. Request JWT
Request a JWT from your OAuth proxy deployed to Edge.  This OAuth proxy is configured automatically when the Edge Microgateway-decorator executes the `init` step.  Make sure to include the client_id and secret from your Apigee product in the curl command below.
```
curl -X POST -H "Content-type: application/json" http://org-env.apigee.net/edgemicro-auth/token -d '{"client_id":"client_id","client_secret":"client_secret","grant_type":"client_credentials"}' -v
```

OR

```
edgemicro token get -o [org] -e [env] -i [client_id] -s [client_secret]
```

Mocked Response (actual JWT is much longer):
```
{ token: 'qOoFoQ4hFQ' }
```

### b. Send the request with Authorization Bearer token header
```
curl -X GET \
-H "Authorization: Bearer qOoFoQ4hFQ" \
http://rest-service.bosh-lite.com/edgemicro_hello/greeting/ -v
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


### How do I execute the Gatling tests?
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

## Automated Testing
I used [Concourse](https://concourse.ci/) to create a set of automated test scripts to confirm that I don't create existing functionality with new features.  See the testing folder.


# MISC

## Troubleshooting - If spring_hello does not work, then follow the steps below to delete/recreate it

### 1. Delete spring_hello
```
cf delete spring_hello
```

### 2. Redeploy to CF
Edge Microgateway v2.1.2
```
cf push spring_hello
```

Edge Microgateway v2.3.1
```
cf push spring_hello -m 512M
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
cf bind-service spring_hello edgemicro_service
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
Tail the logs (i.e. stream events to terminal).
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

## Unbinding/Binding Cloud Foundry Application Security Groups
**DO NOT do this for production servers.  This is only for Bosh-lite running on your local machine.**

If you receive the following error when the staging container is starting, then this means that CF is  unable to send requests to the IP address of your on-premises installation. Make sure that you [update the CF security groups](#update-the-cloud-foundry-staging-security-groups)
```javascript
{ Error: read ECONNRESET
   at exports._errnoException (util.js:1022:11)
   at TCP.onread (net.js:569:26) code: 'ECONNRESET', errno: 'ECONNRESET', syscall: 'read' }
```
If this was already completed, then unbind the security groups.
```
cf unbind-staging-security-group public_networks
cf unbind-running-security-group load_balancer
cf unbind-running-security-group public_networks
cf unbind-running-security-group user_bosh_deployments
cf unbind-running-security-group services
```

and bind them again.
```
cf bind-staging-security-group public_networks
cf bind-running-security-group load_balancer
cf bind-running-security-group public_networks
cf bind-running-security-group user_bosh_deployments
cf bind-running-security-group services
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
1. Document latency between first POC (EM running in separate containers) vs EM running in same container.    

# Open Items
1. Clean up the configure script.
