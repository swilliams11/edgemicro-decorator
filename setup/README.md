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

1. Update the config file

2. Execute the following command
```
./setup/setup_new.sh
```

### Setup Existing
If you already have an installation and you see errors in your VMs then you can use this setup script instead.

1. Update the config file

2. Execute the following command
```
./setup/setup_existing.sh
