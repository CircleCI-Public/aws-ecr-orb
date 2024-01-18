#!/bin/bash
AWS_ECR_EVAL_REGION="$(eval echo "${AWS_ECR_STR_REGION}")"
AWS_ECR_EVAL_PROFILE_NAME="$(eval echo "${AWS_ECR_STR_PROFILE_NAME}")"
AWS_ECR_EVAL_ACCOUNT_ID="$(eval echo "${AWS_ECR_STR_ACCOUNT_ID}")"
AWS_ECR_VAL_ACCOUNT_URL="${AWS_ECR_EVAL_ACCOUNT_ID}.dkr.ecr.${AWS_ECR_EVAL_REGION}.${AWS_ECR_STR_AWS_DOMAIN}"
ECR_COMMAND="ecr"

if [ -z "${AWS_ECR_EVAL_ACCOUNT_ID}" ]; then
  echo "The account ID is not found. Please add the account ID before continuing."
  exit 1
fi

if [ "$AWS_ECR_BOOL_PUBLIC_REGISTRY" == "1" ]; then
    AWS_ECR_EVAL_REGION="us-east-1"
    AWS_ECR_VAL_ACCOUNT_URL="public.ecr.aws"
    ECR_COMMAND="ecr-public"
fi

if [ -n "${AWS_ECR_EVAL_PROFILE_NAME}" ]; then
    set -- "$@" --profile "${AWS_ECR_EVAL_PROFILE_NAME}"
fi

if [ -f "$HOME/.docker/config.json" ] && grep "${AWS_ECR_VAL_ACCOUNT_URL}" < ~/.docker/config.json > /dev/null 2>&1 ; then
    echo "Credential helper is already installed"
else
    docker logout "${AWS_ECR_VAL_ACCOUNT_URL}"
    aws "${ECR_COMMAND}" get-login-password --region "${AWS_ECR_EVAL_REGION}" "$@" | docker login --username AWS --password-stdin "${AWS_ECR_VAL_ACCOUNT_URL}"
fi
