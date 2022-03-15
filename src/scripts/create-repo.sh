#!/bin/bash
REGION=$(eval echo "${PARAM_REGION}")
REPO=$(eval echo "${PARAM_REPO}")

if [ "$PARAM_PUBLIC_REGISTRY" == "1" ]; then
    aws ecr-public describe-repositories --profile "${PARAM_PROFILE_NAME}" --region us-east-1 --repository-names "${REPO}" >/dev/null 2>&1 ||
        aws ecr-public create-repository --profile "${PARAM_PROFILE_NAME}" --region us-east-1 --repository-name "${REPO}"
else
    aws ecr describe-repositories --profile "${PARAM_PROFILE_NAME}" --region "${REGION}" --repository-names "${REPO}" >/dev/null 2>&1 ||
        if [ "$PARAM_REPO_SCAN_ON_PUSH" == "1" ]; then
            aws ecr create-repository --profile "${PARAM_PROFILE_NAME}" --region "${REGION}" --repository-name "${REPO}" --image-scanning-configuration scanOnPush=true
        else
            aws ecr create-repository --profile "${PARAM_PROFILE_NAME}" --region "${REGION}" --repository-name "${REPO}" --image-scanning-configuration scanOnPush=false
        fi
fi
