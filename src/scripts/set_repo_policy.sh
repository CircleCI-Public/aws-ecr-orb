#!/bin/bash
ORB_EVAL_REGION="$(circleci env subst "${ORB_EVAL_REGION}")"
ORB_EVAL_REPO="$(circleci env subst "${ORB_EVAL_REPO}")"
ORB_EVAL_PROFILE_NAME="$(circleci env subst "${ORB_EVAL_PROFILE_NAME}")"
ORB_EVAL_REPO_POLICY_PATH="$(circleci env subst "${ORB_EVAL_REPO_POLICY_PATH}")"

if [ "$ORB_VAL_PUBLIC_REGISTRY" == "1" ]; then
    echo "set-repository-policy is not supported on public repos"
    exit 1
else
    aws ecr set-repository-policy \
        --profile "${ORB_EVAL_PROFILE_NAME}" \
        --region "${ORB_EVAL_REGION}" \
        --repository-name "${ORB_EVAL_REPO}" \
        --policy-text "file://${ORB_EVAL_REPO_POLICY_PATH}"
fi
