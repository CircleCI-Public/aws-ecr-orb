#!/bin/bash
ORB_EVAL_REGION=$(eval echo "${ORB_EVAL_REGION}")
ORB_EVAL_REPO=$(eval echo "${ORB_EVAL_REPO}")

if [ "$ORB_VAL_PUBLIC_REGISTRY" == "1" ]; then
    echo "set-repository-policy is not supported on public repos"
    exit 1
else
    set -x
    aws ecr set-repository-policy \
        --profile "${ORB_VAL_PROFILE_NAME}" \
        --region "${ORB_EVAL_REGION}" \
        --repository-name "${ORB_EVAL_REPO}" \
        --policy-text "file://${ORB_VAL_REPO_POLICY_PATH}"
    set +x
fi
