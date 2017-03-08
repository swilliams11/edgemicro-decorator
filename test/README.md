# Automated Testing with Concourse
[Concourse](https://concourse.ci/) is great CI tool with minimal configuration to setup. I think its much better than Jenkins. I started with Docker following this [tutorial](https://concourse.ci/docker-repository.html).

Once you [Docker](https://www.docker.com/products/overview#/install_the_platform) and Concourse installed and running. Then you execute the following commands to run the automated test scripts.   


### Start Concourse within Docker

1. `git clone git@github.com:concourse/concourse.git`

2. `cd concourse`

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

### Great Concourse Tutorials
https://concourse.ci/flight-school.html

https://github.com/starkandwayne/concourse-tutorial


### Execute flight-school Test Scripts

1. Target your Concourse
```
fly -t ci login -c http://192.168.99.100:8080
```

* username: concourse
* password: changeme


2. Upload the pipeline

```
fly -t ci set-pipeline -p flight-school -c ci/pipeline.yml
```

Once the pipeline is upload, it is paused.

3. Start the pipeline from command line or via the UI.
```
$ fly -t lite unpause-pipeline -p flight-school
```

### Execute test script with property variables

```
fly set-pipeline --target tutorial --config pipeline.yml --pipeline publishing-outputs --non-interactive --load-vars-from ../credentials.yml
```



### Execute edgemicro-decorator Test Scripts

1. Target your Concourse. The `-t ci` will set a name for the hostname, which will be used in subsequent commands.
```
fly -t ci login -c http://192.168.99.100:8080
```

* username: concourse
* password: changeme


2. Upload the pipeline
```
cd edgemicro-decorator
fly -t ci set-pipeline -p edgemicro-decorator -c test/pipeline.yml
```

Once the pipeline is upload, it is paused.

3. Start the pipeline from command line or via the UI.
```
$ fly -t lite unpause-pipeline -p flight-school
```


### Other Concourse commands

#### Delete a pipeline
```
fly -t ci destroy-pipeline -p edgemicro-decorator
```
