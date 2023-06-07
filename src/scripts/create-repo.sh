#!/bin/bash
ORB_EVAL_REGION=$(eval echo "${ORB_EVAL_REGION}")
ORB_EVAL_REPO=$(eval echo "${ORB_EVAL_REPO}")
ORB_EVAL_PROFILE_NAME=$(eval echo "${ORB_EVAL_PROFILE_NAME}")

if [ "$ORB_VAL_PUBLIC_REGISTRY" == "1" ]; then
    aws ecr-public describe-repositories --profile "${ORB_EVAL_PROFILE_NAME}" --region us-east-1 --repository-names "${ORB_EVAL_REPO}" >/dev/null 2>&1 ||
        aws ecr-public create-repository --profile "${ORB_EVAL_PROFILE_NAME}" --region us-east-1 --repository-name "${ORB_EVAL_REPO}"
else
    aws ecr describe-repositories --profile "${ORB_EVAL_PROFILE_NAME}" --region "${ORB_EVAL_REGION}" --repository-names "${ORB_EVAL_REPO}" >/dev/null 2>&1 ||
        if [ "$ORB_VAL_REPO_SCAN_ON_PUSH" == "1" ]; then
            aws ecr create-repository --profile "${ORB_EVAL_PROFILE_NAME}" --region "${ORB_EVAL_REGION}" --repository-name "${ORB_EVAL_REPO}" --image-scanning-configuration scanOnPush=true
        else
            aws ecr create-repository --profile "${ORB_EVAL_PROFILE_NAME}" --region "${ORB_EVAL_REGION}" --repository-name "${ORB_EVAL_REPO}" --image-scanning-configuration scanOnPush=false
        fi
fi
