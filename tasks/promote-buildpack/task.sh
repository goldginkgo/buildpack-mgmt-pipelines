#!/bin/bash

set -eu

cf api $CF_API_URI --skip-ssl-validation
cf auth $CF_USERNAME $CF_PASSWORD

for STACK_NAME in $STACKS;
do
    echo Enabling buildpack ${SOURCE_BUILDPACK_NAME} ${STACK_NAME}...
    cf update-buildpack $SOURCE_BUILDPACK_NAME -s $STACK_NAME --enable

    set +e
    old_buildpack=$(cf buildpacks | grep "${TARGET_BUILDPACK_NAME}\s" | grep "${STACK_NAME}")
    set -e
    if [ -n "$old_buildpack" ]; then
      index=$(echo $old_buildpack | cut -d' ' -f2)
      name=$(echo $old_buildpack | cut -d' ' -f1)

      cf delete-buildpack -f $TARGET_BUILDPACK_NAME -s $STACK_NAME

      echo Updating buildpack ${SOURCE_BUILDPACK_NAME} ${STACK_NAME} index...
      cf update-buildpack $SOURCE_BUILDPACK_NAME -s $STACK_NAME -i $index
    fi

    cf rename-buildpack $SOURCE_BUILDPACK_NAME $TARGET_BUILDPACK_NAME -s $STACK_NAME
done
