# Cloud Foundry Security Groups

These files are provided as a convenience to the user.  You can run the following commands once you cd in to this directory.

***This is not for production deployment. Use this only for local Bosh-lite deployments***

```
cf update-security-group public_networks public_networks2.json
cf update-security-group load_balancer load_balancer.json
cf update-security-group services services.json
cf update-security-group user_bosh_deployments user_bosh_deployments.json
```

Once you execute the above commands you have to restage the app for it to pick up the changes.
```
cf restage spring_hello
```


### Rebinding security Groups
If you already completed the steps above and you still see an error when EM attempts to start, then you can run the following commands to unbind/rebind the security groups.

```
cf unbind-staging-security-group public_networks
cf unbind-running-security-group load_balancer
cf unbind-running-security-group public_networks
cf unbind-running-security-group user_bosh_deployments
cf unbind-running-security-group services
cf bind-staging-security-group public_networks
cf bind-running-security-group load_balancer
cf bind-running-security-group public_networks
cf bind-running-security-group user_bosh_deployments
cf bind-running-security-group services
```
