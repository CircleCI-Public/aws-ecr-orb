#!/bin/bash
PROFILE_NAME=$(eval echo "${PARAM_PROFILE_NAME}")
REGION=$(eval echo "\$${PARAM_REGION}")
REPO=$(eval echo "${PARAM_REPO}")
REPO_SCAN_ON_PUSH=$(eval echo "${PARAM_REPO_SCAN_ON_PUSH}")
PUBLIC_REGISTRY=$(eval echo "${PARAM_PUBLIC_REGISTRY}")
ECR_COMMAND="ecr"

if [ "$PUBLIC_REGISTRY" == "1" ]; then
    REGION="us-east-1"
    ECR_COMMAND="ecr-public"
fi

aws "${ECR_COMMAND}" describe-repositories --profile "${PROFILE_NAME}" --region "${REGION}" --repository-names "${REPO}" > /dev/null 2>&1 || \
if [ "$REPO_SCAN_ON_PUSH" == "1" ]; then
    echo "aws ${ECR_COMMAND} create-repository --profile ${PROFILE_NAME} --region ${REGION} --repository-name ${REPO} --image-scanning-configuration scanOnPush=true" >> test.txt
    aws "${ECR_COMMAND}" create-repository --profile "${PROFILE_NAME}" --region "${REGION}" --repository-name "${REPO}" --image-scanning-configuration scanOnPush=true
else
    aws "${ECR_COMMAND}" create-repository --profile "${PROFILE_NAME}" --region "${REGION}" --repository-name "${REPO}" --image-scanning-configuration scanOnPush=false
fi
