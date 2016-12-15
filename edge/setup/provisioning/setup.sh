#!/bin/sh

source ../setenv.sh

echo "Enter your password for the Apigee Enterprise organization, followed by [ENTER]:"

read -s password

echo using $username and $org

# Install API Products

sh ./setProxy.sh $1

curl -u $username:$password $url/v1/o/$org/apiproducts \
  -H "Content-Type: application/json" -X POST -T EdgemicroProduct.json

mv EdgemicroProduct.json.orig EdgemicroProduct.json

# Create developers

curl -u $username:$password $url/v1/o/$org/developers \
  -H "Content-Type: application/xml" -X POST -T joe.xml

# Create apps

curl -u $username:$password \
  $url/v1/o/$org/developers/joe@weathersample.com/apps \
  -H "Content-Type: application/xml" -X POST -T joe-app.xml

# Get consumer key and attach API product
# Do this in a quick and clean way that doesn't require python or anything

key=`curl -u $username:$password -H "Accept: application/json" \
     $url/v1/o/$org/developers/joe@weathersample.com/apps/joe-app 2>/dev/null \
     | grep consumerKey | awk -F '\"' '{ print $4 }'`

curl -u $username:$password \
  $url/v1/o/$org/developers/joe@weathersample.com/apps/joe-app/keys/${key} \
  -H "Content-Type: application/xml" -X POST -T joe-app-product.xml


key=`curl -u $username:$password -H "Accept: application/json"\
     $url/v1/o/$org/developers/joe@weathersample.com/apps/joe-app 2>/dev/null \
     | grep consumerKey | awk -F '\"' '{ print $4 }'`

echo "Consumer key for joe-app is ${key}\n"
