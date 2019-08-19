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
cf buildpacks | grep cflinuxfs3 > current_buildpacks.txt

./fly -t target get-pipeline -p $PIPELINE > ./pipeline.yml

TRIGGER_JOB_FILE=job-$(date +%Y%m%d-%H%M).txt
> $TRIGGER_JOB_FILE

cat buildpack-mgmt-cmdb/dev1.yml | while read LINE
do 
  echo $LINE
  BUILDPACK=$(echo $LINE | awk -F':' '{print $1}')
  # TODO display erro when buildpack not found

  BUILDPACK_VERSION=$(cat current_buildpacks.txt | grep "$BUILDPACK" | awk '{print $5}' | grep -Eo '[0-9]+[.][0-9]+([.][0-9]+)*')
  echo "$BUILDPACK: Current Version $BUILDPACK_VERSION"
  DESIRED_VERSION=$(echo $LINE | awk '{print $2}')
  echo "$BUILDPACK: Desired Buildpack Version $DESIRED_VERSION"

  if [ $BUILDPACK_VERSION != $DESIRED_VERSION ]; then
    echo "$BUILDPACK: Parsing pipeline file"

    BUILDPACK_CONFIG=$(grep -l "cf-buildpack-name: $BUILDPACK" buildpack-mgmt-pipelines/buildpacks/*.yml)
    BUILDPACK_NAME=$(cat $BUILDPACK_CONFIG | grep "^buildpack-name: " | awk '{print $2}')
    BUILDPACK_REGULATOR_JOB="stage-$BUILDPACK_NAME"
    echo $BUILDPACK_REGULATOR_JOB >> $TRIGGER_JOB_FILE

    # DESIRED_VERSION=3.15
    # staticfile_buildpack-cached-cflinuxfs3-v(3.16.*).zip ->(no change) staticfile_buildpack-cached-cflinuxfs3-v(3.16.*).zip
    # staticfile_buildpack.*cflinuxfs3-v(.*).zip -> staticfile_buildpack.*cflinuxfs3-v(3.15.*).zip
    # staticfile_buildpack.*cflinuxfs3-v(3.16.*).zip -> staticfile_buildpack.*cflinuxfs3-v(3.15.*).zip
    sed "s/$BUILDPACK\.\*cflinuxfs3-v(.*).zip/$BUILDPACK.*cflinuxfs3-v($DESIRED_VERSION.*).zip/" ./pipeline.yml > ./updated-pipeline.yml
    mv ./updated-pipeline.yml ./pipeline.yml
  fi
done

echo "Updating buidpack versions"
./fly -t target set-pipeline -p $PIPELINE -c ./pipeline.yml -n

for BUILDPACK_STAGE_JOB in $(cat $TRIGGER_JOB_FILE); do
  ./fly -t target trigger-job -j $PIPELINE/$BUILDPACK_STAGE_JOB
done

ls -lrt