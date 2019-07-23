#!/bin/bash
set -eu
RESULT_FILE=$(mktemp)

cat templates/base-template.yml > $RESULT_FILE

for vars in $(ls -1 buildpacks/*.yml); do
  TEMP_FILE=$(mktemp)
  echo "Buildpack: $vars"
  bosh int templates/buildpack-template.yml --vars-file=$vars > $TEMP_FILE

  RESULT_TEMP_FILE=$(mktemp)
  spruce merge $RESULT_FILE $TEMP_FILE > $RESULT_TEMP_FILE
  mv $RESULT_TEMP_FILE $RESULT_FILE

  rm $TEMP_FILE
done

for job in $(ls -1 additional/*.yml); do
  echo "Job: $job"
  RESULT_TEMP_FILE=$(mktemp)
  spruce merge $RESULT_FILE $job > $RESULT_TEMP_FILE
  mv $RESULT_TEMP_FILE $RESULT_FILE
done

mv $RESULT_FILE buildpack-installation-pipeline.yml
