# Setup Cloud Foundry on Bosh-lite
The setup tool assumes that Bosh-lite was already installed.  Eventually, I will add that setup to this script.  
This script will install all the necessary components to setup Cloud Foundry on Bosh-lite.

## Prerequisties
* macOS
* Linux* environment
* [Go](https://golang.org/dl/) must be installed and the following environment variable must be set
  * `export GOPATH=/usr/local/go`
* [Homebrew](https://brew.sh/) should be installed.
* [Bosh-lite](https://github.com/cloudfoundry/bosh-lite) should be installed and running
  * Set the Bosh target to your local instance and login
  ```
  bosh target 192.168.50.4 lite
  ```

## Setup Script Actions
* Installs Spiff with Homebrew.
* Uploads a stem cell to Bosh.
* Check-out `cf-release` Github repository and run the setup scripts there.

## Setup

### New Setup
For a new installations use this script.

1. Update the `setup_cf_app.sh` file to include the appropriate service definition.
For example, change
```
cf cups edgemicro_service -p 'REPLACE ME'
```

To

```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "tags": ["edgemicro"]}'
```

2. Execute the following command:
```
./setup/setup_new.sh
```

3. Execute the following command:
This script will:
* push the spring application to CF
* create the user defined service that was defined in step 1
* bind the service to the app
* enable diego on the app
* start the app

```
./setup/setup_cf_app.sh
```

### Setup Existing
If you already have already installed and you see errors in your VMs then you can use this setup script instead.

1. Update the `setup_cf_app.sh` file to include the appropriate service

For example, change
```
cf cups edgemicro_service -p 'REPLACE ME'
```

To

```
cf cups edgemicro_service -p '{"application_name":"edgemicro_service", "org":"apigee_org", "env":"apigee_env", "user":"apigee_username","pass":"apigee_password", "edgemicro_version":"2.3.1", "edgemicro_port":"8080", "tags": ["edgemicro"]}'
```


2. Execute the following command
```
./setup/setup_existing.sh
```

3. Execute the following command:
This script will:
* push the spring application to CF
* create the user defined service that was defined in step 1
* bind the service to the app
* enable diego on the app
* start the app

```
./setup/setup_cf_app.sh
```

### Troubleshooting errors

#### Error 100: Permission denied
If you see the following error in the console, then there is a permission issue in the bosh-lite VM.

```
Director task 15
Deprecation: Ignoring cloud config. Manifest contains 'networks' section.

  Started preparing deployment > Preparing deployment. Done (00:00:02)

  Started preparing package compilation > Finding packages to compile. Failed: Permission denied @ dir_s_mkdir - /vagrant/tmp (00:00:00)

Error 100: Permission denied @ dir_s_mkdir - /vagrant/tmp

Task 15 error

For a more detailed error report, run: bosh task 15 --debug
```

Fix this by executing the following commands:
```
cd bosh-lite
vagrant ssh
sudo chown -cR vcap:vcap /vagrant/
```

#### FAILED Error read/writing config:  unexpected end of JSON input

If you receive the following error then the `/Users/[username]/.cf/config.json` file needs to be deleted.
```
FAILED
Error read/writing config:  unexpected end of JSON input
```
