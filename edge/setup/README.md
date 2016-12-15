# Edgemicro Setup

This directory provides scripts that configure your local environment and deploy a sample Edge Microgateway proxy to your organization on the Apigee API Platform.

### Prerequisites

Make sure you have the following installed and available on your PATH (recognizable when you run, for example, <code>which curl</code>).

* cURL
* Python
* **Cygwin on Windows**: If you're running Cygwin on Windows, you'll also need the **doc2unix** utility. (The Cygwin installer lets you install the utility.) See the [Windows/Cygwin Troubleshooting] (#windowscygwin-troubleshooting) section for more information.


### Directions

1. If you do not have an account yet, [register one for free](https://accounts.apigee.com/accounts/sign_up).

2. In the file `setenv.sh`, configure values for your organization, username, environment.

3. Deploy the `edgemicro_cloudfoundry` proxy. Run `deploy.sh` from the `./setup` directory.

4. When prompted, enter `edgemicro_cloudfoundry`

5. Enter your org admin password when prompted.  

6. The script prompts you to provision the API product, App and developer. Type `yes` to deploy these to your Edge organization and environment.  Follow the command prompts.

You can now go to the Apigee management UI and see the deployed proxy.

Alternatively, you can invoke the proxies from the command line. To do so, cd to the `/edgemicro_cloudfoundry` directory, which contains an `deploy.sh` file.

### Ask the community

[![alt text](../images/apigee-community.png "Apigee Community is a great place to ask questions and find answers about developing API proxies. ")](https://community.apigee.com?via=github)

---

Copyright © 2015 Apigee Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy
of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
