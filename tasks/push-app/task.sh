#!/bin/bash

set -eu

cf api $CF_API_URI --skip-ssl-validation
cf auth $CF_USERNAME $CF_PASSWORD

cf target -o $CF_ORG -s $CF_SPACE

cd app/
cf push -b $BUILDPACK_NAME -s $STACKS $APP_NAME
cd -
