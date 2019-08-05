#!/bin/bash
set -eux

ls -lrt

echo "Triggering buildpack update from CMDB"
wget -Ofly "http://$FLY_HOST/api/v1/cli?arch=amd64&platform=linux" --no-check-certificate
chmod +x fly

./fly -t target login -c http://$FLY_HOST -n $FLY_TEAM -u $FLY_USERNAME -p $FLY_PASSWORD --insecure
./fly -t target sync

cf api $CF_API_URI --skip-ssl-validation
cf auth $CF_USERNAME $CF_PASSWORD

BUILDPACK_VERSION=$(cf buildpacks | grep cflinuxfs3 | grep staticfile_buildpack | awk '{print $5}' | grep -Eo '[0-9]+[.][0-9]+([.][0-9]+)*')
echo "Current Buildpack Version: $BUILDPACK_VERSION"
DESIRED_VERSION=$(cat buildpack-mgmt-cmdb/US1.yml | grep "^staticfile_buildpack: " | awk '{print $2}')
echo "Desired Buildpack Version: $DESIRED_VERSION"

if [ $BUILDPACK_VERSION != $DESIRED_VERSION ]; then
  echo "Update buildpack regex for exisiting pipeline"
  ./fly -t target get-pipeline -p $PIPELINE > ./original-pipeline.yml

  echo "Original paipeline:"
  cat ./original-pipeline.yml

  # DESIRED_VERSION=3.15
  # staticfile_buildpack-cached-cflinuxfs3-v(?<version>3.16.*).zip ->(no change) staticfile_buildpack-cached-cflinuxfs3-v(?<version>3.16.*).zip
  # staticfile_buildpack-.*-cflinuxfs3-v(?<version>.*).zip -> staticfile_buildpack.*cflinuxfs3-v(?<version>3.15.*).zip
  # staticfile_buildpack.*cflinuxfs3-v(?<version>3.16.*).zip -> staticfile_buildpack.*cflinuxfs3-v(?<version>3.15.*).zip
  sed "s/staticfile_buildpack\.\*cflinuxfs3-v(?<version>.*).zip/staticfile_buildpack.*cflinuxfs3-v(?<version>$DESIRED_VERSION.*).zip/" ./original-pipeline.yml > ./updated-pipeline.yml

  ./fly -t target set-pipeline -p $PIPELINE -c ./updated-pipeline.yml -n

  echo "Update staticfile buidpack for $DESIRED_VERSION"
  BUILDPACK_STAGE_JOB="stage-staticfile-buildpack"
  ./fly -t target trigger-job -j $PIPELINE/$BUILDPACK_STAGE_JOB
fi
