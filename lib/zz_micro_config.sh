#!/bin/bash

# The *-config.py program will directly manipulate things like
# configuration files. But it can not directly manipulate the
# environment variables, as that would only affect its process
# hierarchy. So for environment variables, we have it provide
# us with the keys and values on its output stream, and we place
# them in exported environment variables, here - in the parent
# process - which will also be the parent for the application.

# while read key value
# do
# 	echo "setting $key to $value"
# 	export "$key"="$value"
# done <<< "`python ~/apigee_edge_micro/micro_config.py`"

### cf start or restart executes this code
