echo "For Edgemicro, you need to run setup.sh in /setup/provisioning directory to install sample API product, developer and app in your org."

echo "Do you want to run now? ([yes]/no):"

read provision

if [ -z $provision ] || [ "$provision" = "yes" ]; then
        cd provisioning
	echo "Clearing old data"
	sh ./cleanup.sh
	sh ./setup.sh $1
	cd -
else
	echo "Make sure you provision the Api Product and Developer, before testing"
fi

echo "Deployment Completed"
