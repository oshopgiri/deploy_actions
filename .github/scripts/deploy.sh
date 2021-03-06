#!/bin/bash
source $REMOTE_SCRIPT_DIRECTORY/utils.sh

version_exists=$(
  ebs_check_application_version \
    "$AWS_EBS_APPLICATION_NAME" \
    $VERSION_LABEL
)

if $version_exists
then
  echo "Existing application version found on EBS: $VERSION_LABEL, skipping version creation..."
else
  echo "Creating new EBS application version..."
  ebs_create_application_version \
    "$AWS_EBS_APPLICATION_NAME" \
    $S3_BUCKET_NAME \
    $S3_BUILD_KEY \
    "$VERSION_LABEL"

  version_exists=$(
    ebs_check_application_version \
      "$AWS_EBS_APPLICATION_NAME" \
      $VERSION_LABEL
  )
  if $version_exists
  then
    echo "Created new EBS application version: $VERSION_LABEL"
  else
    exit 1
  fi
fi

echo "Deploying version '$VERSION_LABEL' to EBS application '$AWS_EBS_APPLICATION_NAME', environment '$AWS_EBS_ENVIRONMENT_NAME'"
ebs_deploy_application_version \
  $AWS_EBS_ENVIRONMENT_NAME \
  "$VERSION_LABEL"

exit 0

# Exit codes
# 0 - success
# 1 - ebs_version_creation_failed
