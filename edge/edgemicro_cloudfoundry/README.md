# edgemicro_cloudfoundry

The directory `/apiproxy` contains a sample API proxy for the edgemicro proxy.

# Configure

This sample requires you to create a set of developers, apps, and API products in your organization. To create these entities, run the scripts under `../setup`. Follow the instructions in `../setup/README`.


1. Update `/setup/setenv.sh` with your organization name and email address.

2. Run `/setup/provisioning/setup.sh`

# Import and deploy sample project

To deploy, run `./deploy.sh`

To test, run `./invoke.sh`

### Get help

For assistance, please use [Apigee Support](https://community.apigee.com/content/apigee-customer-support).

Copyright © 2014, 2015 Apigee Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy
of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
