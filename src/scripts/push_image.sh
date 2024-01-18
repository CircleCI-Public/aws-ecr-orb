#!/bin/bash
AWS_ECR_EVAL_REPO="$(eval echo "${AWS_ECR_STR_REPO}")"
AWS_ECR_EVAL_TAG="$(eval echo "${AWS_ECR_STR_TAG}")"
AWS_ECR_EVAL_REGION="$(eval echo "${AWS_ECR_STR_REGION}")"
AWS_ECR_EVAL_ACCOUNT_ID="$(eval echo "${AWS_ECR_STR_ACCOUNT_ID}")"
AWS_ECR_VAL_ACCOUNT_URL="${AWS_ECR_EVAL_ACCOUNT_ID}.dkr.ecr.${AWS_ECR_EVAL_REGION}.amazonaws.com"
AWS_ECR_EVAL_PUBLIC_REGISTRY_ALIAS="$(eval echo "${AWS_ECR_STR_PUBLIC_REGISTRY_ALIAS}")"

echo "$AWS_ECR_VAL_ACCOUNT_URL" >> test.txt

if [ -z "${AWS_ECR_EVAL_ACCOUNT_ID}" ]; then
  echo "The account ID is not found. Please add the account ID before continuing."
  exit 1
fi

if [ "${AWS_ECR_BOOL_PUBLIC_REGISTRY}" == "1" ]; then
  AWS_ECR_VAL_ACCOUNT_URL="public.ecr.aws/${AWS_ECR_EVAL_PUBLIC_REGISTRY_ALIAS}"
fi

IFS="," read -ra DOCKER_TAGS <<< "${AWS_ECR_EVAL_TAG}"
for tag in "${DOCKER_TAGS[@]}"; do
set -x
    docker push "${AWS_ECR_VAL_ACCOUNT_URL}/${AWS_ECR_EVAL_REPO}:${tag}"
set +x
done