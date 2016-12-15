#!/bin/sh

source ./../setenv.sh

echo "Enter your password for the Apigee Enterprise organization, followed by [ENTER]:"

read -s password

echo using $username and $org

echo "Deleting Apps"

curl -u $username:$password $url/v1/o/$org/developers/joe@weathersample.com/apps/joe-app -X DELETE

echo "Deleting Developers"

curl -u $username:$password $url/v1/o/$org/developers/joe@weathersample.com -X DELETE

echo "Deleting Products"

curl -u $username:$password $url/v1/o/$org/apiproducts/EdgemicroProduct -X DELETE

echo "\nCleanup Completed\n"
