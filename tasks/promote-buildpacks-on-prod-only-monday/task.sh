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

  BUILDPACKS_TO_UPDATE=$(cat buildpack-state-test/state-*.txt)
  for BUILDPACK_NAME in $BUILDPACKS_TO_UPDATE; do
    echo "Update $BUILDPACK_NAME"
    BUILDPACK_REGULATOR_JOB="production-regulator-$BUILDPACK_NAME"
    ./fly -t target trigger-job -j $PIPELINE/$BUILDPACK_REGULATOR_JOB
  done
else
  echo "This script does nothing on other days then Monday, exit"
  exit -1
fi

