# Cloud Foundry Test Scripts with Shell Scripts
This folder contains the test scripts for edgemicro-decorator.  This test script uses apickli to execute the test scripts.


### Update config.sh
Update config.sh with the appropriate values.

### Execute the test script

1. `cd edgemicro-decorator/test`

2. `./test-edgemicro-decorator-task.sh`




# Cloud Foundry Test with Apickli
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
