#!/bin/bash
set -eu
# Exit with day of week, 0 is Monday
if [[ "$(($(date +%u)-1))" == "0" ]]; then
  echo "Update buildpacks"
  wget -Ofly "https://$FLY_HOST/api/v1/cli?arch=amd64&platform=linux" --no-check-certificate
  chmod +x fly

  ./fly -t target login -c https://$FLY_HOST -n $FLY_TEAM -u $FLY_USERNAME -p $FLY_PASSWORD --insecure

  cf api $CF_API_URI --skip-ssl-validation
  cf auth $CF_USERNAME $CF_PASSWORD

  mkdir -p buildpack-state-test
  BUILDPACK_STATE_FILENAME=buildpack-state-test/state-$(date +%Y%m%d-%H%M).txt
  > $BUILDPACK_STATE_FILENAME
  BUILDPACKS_TO_UPDATE=$(cf buildpacks | grep ^[^\ ]*_latest\ | awk '{print $1}')
  for BUILDPACK in $BUILDPACKS_TO_UPDATE; do
    BUILDPACK_CONFIG=$(grep -l "cf-latest-buildpack-name: $BUILDPACK" ci-buildpacks/buildpacks/*.yml)
    BUILDPACK_NAME=$(cat $BUILDPACK_CONFIG | grep "^buildpack-name: " | awk '{print $2}')
    echo "Update $BUILDPACK_NAME"
    echo $BUILDPACK_NAME >> $BUILDPACK_STATE_FILENAME
    BUILDPACK_REGULATOR_JOB="test-regulator-$BUILDPACK_NAME"
    ./fly -t target trigger-job -j $PIPELINE/$BUILDPACK_REGULATOR_JOB
  done
else
  echo "This script does nothing on other days then Monday, exit"
  exit -1
fi

