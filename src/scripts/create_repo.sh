#!/bin/bash
ORB_STR_REGION="$(circleci env subst "${ORB_STR_REGION}")"
ORB_STR_REPO="$(circleci env subst "${ORB_STR_REPO}")"
ORB_STR_PROFILE_NAME="$(circleci env subst "${ORB_STR_PROFILE_NAME}")"

if [ "$ORB_BOOL_PUBLIC_REGISTRY" == "1" ]; then
    aws ecr-public describe-repositories --profile "${ORB_STR_PROFILE_NAME}" --region us-east-1 --repository-names "${ORB_STR_REPO}" >/dev/null 2>&1 ||
        aws ecr-public create-repository --profile "${ORB_STR_PROFILE_NAME}" --region us-east-1 --repository-name "${ORB_STR_REPO}"
else
    aws ecr describe-repositories --profile "${ORB_STR_PROFILE_NAME}" --region "${ORB_STR_REGION}" --repository-names "${ORB_STR_REPO}" >/dev/null 2>&1 ||
        if [ "$ORB_BOOL_REPO_SCAN_ON_PUSH" == "1" ]; then
            aws ecr create-repository --profile "${ORB_STR_PROFILE_NAME}" --region "${ORB_STR_REGION}" --repository-name "${ORB_STR_REPO}" --image-scanning-configuration scanOnPush=true
        else
            aws ecr create-repository --profile "${ORB_STR_PROFILE_NAME}" --region "${ORB_STR_REGION}" --repository-name "${ORB_STR_REPO}" --image-scanning-configuration scanOnPush=false
        fi
fi
