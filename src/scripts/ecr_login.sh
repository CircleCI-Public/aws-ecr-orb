#!/bin/bash
ORB_EVAL_REGION="$(eval echo "${ORB_STR_REGION}")"
ORB_EVAL_PROFILE_NAME="$(eval echo "${ORB_STR_PROFILE_NAME}")"
ORB_EVAL_ACCOUNT_ID="$(eval echo "${ORB_STR_ACCOUNT_ID}")"
ORB_VAL_ACCOUNT_URL="${ORB_EVAL_ACCOUNT_ID}.dkr.ecr.${ORB_EVAL_REGION}.${ORB_EVAL_AWS_DOMAIN}"
ECR_COMMAND="ecr"

if [ -z "${ORB_EVAL_ACCOUNT_ID}" ]; then
  echo "The account ID is not found. Please add the account ID before continuing."
  exit 1
fi

if [ "$ORB_BOOL_PUBLIC_REGISTRY" == "1" ]; then
    ORB_EVAL_REGION="us-east-1"
    ORB_VAL_ACCOUNT_URL="public.ecr.aws"
    ECR_COMMAND="ecr-public"
fi

if [ -n "${ORB_EVAL_PROFILE_NAME}" ]; then
    set -- "$@" --profile "${ORB_EVAL_PROFILE_NAME}"
fi

if [ -f "$HOME/.docker/config.json" ] && grep "${ORB_VAL_ACCOUNT_URL}" < ~/.docker/config.json > /dev/null 2>&1 ; then
    echo "Credential helper is already installed"
else
    docker logout "${ORB_VAL_ACCOUNT_URL}"
    aws "${ECR_COMMAND}" get-login-password --region "${ORB_EVAL_REGION}" "$@" | docker login --username AWS --password-stdin "${ORB_VAL_ACCOUNT_URL}"
fi
