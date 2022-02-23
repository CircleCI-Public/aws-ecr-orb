#!/bin/bash
PROFILE_NAME=$(eval echo "${PARAM_PROFILE_NAME}")
REGION=$(eval echo "\$${PARAM_REGION}")
REPO=$(eval echo "${PARAM_REPO}")
REPO_SCAN_ON_PUSH=$(eval echo "${PARAM_REPO_SCAN_ON_PUSH}")
PUBLIC_REGISTRY=$(eval echo "${PARAM_PUBLIC_REGISTRY}")


if [ "$PUBLIC_REGISTRY" == "1" ]; then
    aws ecr-public describe-repositories --profile "${PROFILE_NAME}" --region us-east-1 --repository-names "${REPO}" > /dev/null 2>&1 || \
    aws ecr-public create-repository --profile "${PROFILE_NAME}" --region us-east-1 --repository-name "${REPO}"
else
    aws ecr describe-repositories --profile "${PROFILE_NAME}" --region "${REGION}" --repository-names "${REPO}" > /dev/null 2>&1 || \
    if [ "$REPO_SCAN_ON_PUSH" == "1" ]; then
        aws ecr create-repository --profile "${PROFILE_NAME}" --region "${REGION}" --repository-name "${REPO}" --image-scanning-configuration scanOnPush=true
    else
        aws ecr create-repository --profile "${PROFILE_NAME}" --region "${REGION}" --repository-name "${REPO}" --image-scanning-configuration scanOnPush=false
    fi
fi

