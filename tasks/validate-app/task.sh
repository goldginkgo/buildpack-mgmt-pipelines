#!/bin/bash

set -eux
#set -o pipefail

#echo "...Show environment variables..."
#env

echo "...Show current directory..."
ls -altr

echo "...Log in to Cloud Foundry..."
cf api $CF_API_URI --skip-ssl-validation
cf auth $CF_USERNAME $CF_PASSWORD
cf target -o $CF_ORG -s $CF_SPACE

set +e
echo "...Validate / for the test app..."
curl -L https://$APP_NAME.$CF_APP_URL --insecure
curl -L https://$APP_NAME.$CF_APP_URL --insecure | grep 'Hello World!' &> /dev/null
retVal=$?
set -e

if [ $retVal -eq 0 ]; then
  echo "...Delete test app..."
  cf delete $APP_NAME -r -f

  echo "...Show current buildpacks..."
  cf buildpacks
else
  echo "...Delete app..."
  cf delete $APP_NAME -r -f

  exit 1
fi
