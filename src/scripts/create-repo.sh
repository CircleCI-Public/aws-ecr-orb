#!/bin/bash

if [ "$PARAM_PUBLIC_REGISTRY" == "1" ]; then
    aws ecr-public describe-repositories --profile "${PARAM_PROFILE_NAME}" --region us-east-1 --repository-names "${PARAM_REPO}" >/dev/null 2>&1 ||
        aws ecr-public create-repository --profile "${PARAM_PROFILE_NAME}" --region us-east-1 --repository-name "${PARAM_REPO}"
else
    aws ecr describe-repositories --profile "${PARAM_PROFILE_NAME}" --region "${PARAM_REGION}" --repository-names "${PARAM_REPO}" >/dev/null 2>&1 ||
        if [ "$PARAM_REPO_SCAN_ON_PUSH" == "1" ]; then
            aws ecr create-repository --profile "${PARAM_PROFILE_NAME}" --region "${PARAM_REGION}" --repository-name "${PARAM_REPO}" --image-scanning-configuration scanOnPush=true
        else
            aws ecr create-repository --profile "${PARAM_PROFILE_NAME}" --region "${PARAM_REGION}" --repository-name "${PARAM_REPO}" --image-scanning-configuration scanOnPush=false
        fi
fi
