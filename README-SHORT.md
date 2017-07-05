# edgemicro-decorator short version
This is the short version of the edgemicro-decorator documentation.

** Please note that the edgemicro-decorator will execute only if you bind the Cloud Foundry app to the `edgemicro_service`.**

1. You must have access to Edge. And you must complete the following.
  a) Create an edgemicro aware proxy.
  b) Create an Apigee product.
  c) Create an Apigee App.

  These steps are detailed [here](http://docs.apigee.com/microgateway/latest/setting-and-configuring-edge-microgateway#Part2).

  The only difference is that your `Proxy Base Path` will be `/edgemicro_hello` and
  your `Existing API` will be http://localhost:8090.

2. Install and start [PCF Dev](https://pivotal.io/platform/pcf-tutorials/getting-started-with-pivotal-cloud-foundry-dev/introduction).

NOTE: you can stop after you execute the `cf dev start` command.

Next execute the following command to login to PCF Dev:
```
cf login -a api.local.pcfdev.io --skip-ssl-validation
```

And enter the following when prompted.
```
API endpoint:  api.local.pcfdev.io   
Email>     admin
Password>  admin
```

3. Clone meta-buildpack decorator and upload it to PCF Dev.
```
git clone git@github.com:cf-platform-eng/meta-buildpack.git
cd meta-buildpack
./build
./upload
```

4. Clone the edgemicro-decorator and upload it to PCF Dev.
Please note that this repo will eventually be moved to /apigee/edgemicro-decorator location.

```
git clone https://github.com/swilliams11/edgemicro-decorator.git
cd edgemicro-decorator
./upload
```

5. Clone the Spring Boot hello world sample application and push it to PCF Dev.

```
git clone https://github.com/spring-guides/gs-rest-service.git
cd gs-rest-service/complete
```

You must modify the `manifest.yaml` file with the changes shown below.
```
name: spring_hello
domain: local.pcfdev.io

env:
  JBP_CONFIG_JAVA_MAIN: '{arguments: "--server.port=8090"}'
```

Build the jar file:
```
./gradlew build
```

Then push the application to PCF Dev and enable diego.

Make sure to install the Diego plugin first.  
```
https://github.com/cloudfoundry-incubator/Diego-Enabler
```

```
cf push --no-start -m 512M
cf enable-diego spring_hello
```

6. Create the Edge Microgateway User Defined Service Instance with the following command.
However, you must update all the fields with CHANGEME.

```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"CHANGEME", "env":"CHANGEME", "user":"CHANGEME","pass":"CHANGEME", "nodejs_version_number": "6.10.2", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "onpremises": "true", "onprem_config" : {"runtime_url": "http://CHANGEME:9001", "mgmt_url" : "http://CHANGEME:8080", "virtual_host" : "default"}, "tags": ["edgemicro"]}'
```

Bind the service to the Cloud Foundry App
```
cf bind-service spring_hello edgemicro_service
```

7. Restart the spring_hello service
```
cf restage spring_hello
```

8. Test the service.

Will fail without a valid token.
```
curl http://rest-service.local.pcfdev.io/edgemicro_hello
```

Get a valid token.
```
curl -X POST "http://CHANGEME/edgemicro-auth/token" -H "Content-type: application/json" -d '{"client_id":"CHANGEME","client_secret":"CHANGEME","grant_type":"client_credentials"}'
```

Send request to CF with a valid token.
```
curl http://rest-service.local.pcfdev.io/edgemicro_hello -H "Authorization: Bearer CHANGEME_JWT"
```
