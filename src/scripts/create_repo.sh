#!/bin/bash
ORB_STR_REGION="$(eval echo "${ORB_STR_REGION}")"
ORB_STR_REPO="$(eval echo "${ORB_STR_REPO}")"
ORB_STR_PROFILE_NAME="$(eval echo "${ORB_STR_PROFILE_NAME}")"
ORB_STR_ENCRYPTION_KMS_KEY="$(eval echo "${ORB_STR_ENCRYPTION_KMS_KEY}")"

if [ "$ORB_BOOL_PUBLIC_REGISTRY" == "1" ]; then
    aws ecr-public describe-repositories --profile "${ORB_STR_PROFILE_NAME}" --region us-east-1 --repository-names "${ORB_STR_REPO}" >/dev/null 2>&1 ||
        aws ecr-public create-repository --profile "${ORB_STR_PROFILE_NAME}" --region us-east-1 --repository-name "${ORB_STR_REPO}"
else

    IMAGE_SCANNING_CONFIGURATION="scanOnPush=true"
    if [ "$ORB_BOOL_REPO_SCAN_ON_PUSH" -ne "1" ]; then
      IMAGE_SCANNING_CONFIGURATION="scanOnPush=false"
    fi

    ENCRYPTION_CONFIGURATION="encryptionType=${ORB_ENUM_ENCRYPTION_TYPE}"
    if [ "$ORB_ENUM_ENCRYPTION_TYPE" == "KMS"  ]; then
      ENCRYPTION_CONFIGURATION+=",kmsKey=${ORB_STR_ENCRYPTION_KMS_KEY}"
    fi

    aws ecr describe-repositories \
      --profile "${ORB_STR_PROFILE_NAME}" \
      --region "${ORB_STR_REGION}" \
      --repository-names "${ORB_STR_REPO}" >/dev/null 2>&1 ||
        aws ecr create-repository \
          --profile "${ORB_STR_PROFILE_NAME}" \
          --region "${ORB_STR_REGION}" \
          --repository-name "${ORB_STR_REPO}" \
          --image-scanning-configuration "${IMAGE_SCANNING_CONFIGURATION}" \
          --encryption-configuration "${ENCRYPTION_CONFIGURATION}"
fi
