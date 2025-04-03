#!/bin/bash
set -x
AWS_ECR_EVAL_ACCOUNT_ID="$(eval echo "${AWS_ECR_STR_ACCOUNT_ID}")"
AWS_ECR_EVAL_REGION="$(eval echo "${AWS_ECR_STR_REGION}")"
AWS_ECR_EVAL_REPO="$(eval echo "${AWS_ECR_STR_REPO}")"
AWS_ECR_EVAL_PROFILE_NAME="$(eval echo "${AWS_ECR_STR_PROFILE_NAME}")"
AWS_ECR_EVAL_REPO_TAG="$(eval echo "${AWS_ECR_STR_REPO_TAG}")"

if [ "$AWS_ECR_BOOL_PUBLIC_REGISTRY" == "1" ]; then
    echo "repo_tag is not supported on public repos"
    exit 1
fi

if [ -z "${AWS_ECR_STR_REPO_TAG}" ]; then
    AWS_ECR_EVAL_REPO_TAG="{\"Key\": \"Name\", \"Value\": \""${AWS_ECR_EVAL_REPO}\""}"
fi
aws ecr tag-resource \
    --profile "${AWS_ECR_EVAL_PROFILE_NAME}" \
    --region "${AWS_ECR_EVAL_REGION}" \
    --resource-arn "arn:aws:ecr:${AWS_ECR_EVAL_REGION}:${AWS_ECR_EVAL_ACCOUNT_ID}:repository/${AWS_ECR_EVAL_REPO}" \
    --tags "${AWS_ECR_EVAL_REPO_TAG}"
set +x
