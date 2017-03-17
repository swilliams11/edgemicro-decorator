# Cloud Foundry Tests with Shell Scripts and Apickli
This folder contains the test scripts for edgemicro-decorator.  This test script uses apickli to execute the test scripts.

You must have pcf-dev running on your local machine.  

### Update config.sh
Update config.sh with the appropriate values. This will execute all the tests against pcfdev.

### Update Apickli test fixtures
Make sure to change the client id and secret to the one for your Apigee org/env.
`test/features/fixtures/token.json`

### Update edgemicro.js Auth Token edgeAuthTokenEndpoint

Make sure to update the following file with the correct Edge Auth token endpoint for Microgateway.  
i.e http://mydomainorIP:9001/edgemicro-auth/token

`test/features/step_definitions/edgemicro.js`

### Execute the test script

1. `cd edgemicro-decorator/test`

2. `./test-edgemicro-decorator-apickli.sh all`

Or you can run each test individually by entering the test name on the command line.
`./test-edgemicro-decorator-apickli.sh test1`

There are 7 tests in total.
`test1` ... `test7`


# Cloud Foundry Test with Concourse (Progress HALTED)
This folder contains the test scripts for edgemicro-decorator.  This test script uses apickli to execute the test scripts.


### Update config.sh
Update config.sh with the appropriate values.

### Execute the test script

1. `cd edgemicro-decorator/test`

2. `./test-edgemicro-decorator-task.sh`

3. `docker-machine start default`

4. Run this command to configure your terminal with your default docker environment.
```
eval $(docker-machine env default)
```
5. `docker-compose up`

6. Execute `docker env` to get the IP address of your docker machine.

Concourse UI is accessible at
```
[dockerhostname]:8080
```
i.e.
```
http://192.168.99.100:8080
```
