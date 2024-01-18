#!/bin/bash
AWS_ECR_EVAL_REGION="$(eval echo "${AWS_ECR_STR_REGION}")"
AWS_ECR_EVAL_REPO="$(eval echo "${AWS_ECR_STR_REPO}")"
AWS_ECR_EVAL_PROFILE_NAME="$(eval echo "${AWS_ECR_STR_PROFILE_NAME}")"
AWS_ECR_EVAL_REPO_POLICY_PATH="$(eval echo "${AWS_ECR_STR_REPO_POLICY_PATH}")"

if [ "$AWS_ECR_BOOL_PUBLIC_REGISTRY" == "1" ]; then
    echo "set-repository-policy is not supported on public repos"
    exit 1
else
    aws ecr set-repository-policy \
        --profile "${AWS_ECR_EVAL_PROFILE_NAME}" \
        --region "${AWS_ECR_EVAL_REGION}" \
        --repository-name "${AWS_ECR_EVAL_REPO}" \
        --policy-text "file://${AWS_ECR_EVAL_REPO_POLICY_PATH}"
fi
