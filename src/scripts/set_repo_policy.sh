#!/bin/bash
ORB_STR_REGION="$(eval echo "${ORB_STR_REGION}")"
ORB_STR_REPO="$(eval echo "${ORB_STR_REPO}")"
ORB_STR_PROFILE_NAME="$(eval echo "${ORB_STR_PROFILE_NAME}")"
ORB_STR_REPO_POLICY_PATH="$(eval echo "${ORB_STR_REPO_POLICY_PATH}")"

if [ "$ORB_BOOL_PUBLIC_REGISTRY" == "1" ]; then
    echo "set-repository-policy is not supported on public repos"
    exit 1
else
    aws ecr set-repository-policy \
        --profile "${ORB_STR_PROFILE_NAME}" \
        --region "${ORB_STR_REGION}" \
        --repository-name "${ORB_STR_REPO}" \
        --policy-text "file://${ORB_STR_REPO_POLICY_PATH}"
fi
