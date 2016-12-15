#!/bin/sh

#Backup the original ApiProduct Payload

if [ ! -f EdgemicroProduct.json.orig ]; then
	cp EdgemicroProduct.json EdgemicroProduct.json.orig
fi

if [ -z $1 ]; then
	echo "Enter the ApiProxy(ies) to attach in ApiProduct (Comma separated):"
	while [ -z $apiproxy ]; do
		read apiproxy
	done
else
	apiproxy=$1
fi


value=$apiproxy
apiproxy=`echo $value | sed -e 's/ //g' | sed -e 's/,/","/g'`

echo "Filling the ProxyDetail in ApiProduct"

TMP_FILE=`mktemp /tmp/config.XXXXXXXXXX`
sed -e "s/PROXY/\"$apiproxy\"/" EdgemicroProduct.json > $TMP_FILE
mv $TMP_FILE EdgemicroProduct.json
