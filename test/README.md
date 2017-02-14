# Automated Testing with Concourse
[Concourse](https://concourse.ci/) is great CI tool with minimal configuration to setup. I think its much better than Jenkins. I started with Docker following this [tutorial](https://concourse.ci/docker-repository.html).

Once you [Docker](https://www.docker.com/products/overview#/install_the_platform) and Concourse installed and running. Then you execute the following commands to run the automated test scripts.   


### Great Tutorials
https://concourse.ci/flight-school.html

https://github.com/starkandwayne/concourse-tutorial


### Execute Test Scripts

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
