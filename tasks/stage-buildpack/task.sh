#!/bin/bash

set -eu

cf api $CF_API_URI --skip-ssl-validation
cf auth $CF_USERNAME $CF_PASSWORD


for STACK_NAME in $STACKS;
do
    set +e
    existing_buildpack=$(cf buildpacks | grep "${BUILDPACK_NAME}\s" | grep "${STACK_NAME}")
    set -e
    if [ -z "${existing_buildpack}" ]; then
      COUNT=$(cf buildpacks | grep --regexp=".zip" --count)
      NEW_POSITION=$(expr $COUNT + 1)
      cf create-buildpack $BUILDPACK_NAME buildpack/*-$STACK_NAME-*.zip $NEW_POSITION --enable
    else
      index=$(echo $existing_buildpack | cut -d' ' -f2)
      cf update-buildpack $BUILDPACK_NAME -p buildpack/*-$STACK_NAME-*.zip -s $STACK_NAME -i $index --enable
    fi
done