#!/bin/bash
ORB_STR_REGION="$(circleci env subst "${ORB_STR_REGION}")"
ORB_STR_PROFILE_NAME="$(circleci env subst "${ORB_STR_PROFILE_NAME}")"
ORB_VAL_ACCOUNT_URL="${!ORB_STR_ACCOUNT_ID}.dkr.ecr.${ORB_STR_REGION}.${ORB_STR_AWS_DOMAIN}"
ECR_COMMAND="ecr"

if [ -z "${!ORB_STR_ACCOUNT_ID}" ]; then
  echo "The registry ID is not found. Please add the registry ID as an environment variable in CicleCI before continuing."
  exit 1
fi

if [ "$ORB_BOOL_PUBLIC_REGISTRY" == "1" ]; then
    ORB_STR_REGION="us-east-1"
    ORB_VAL_ACCOUNT_URL="public.ecr.aws"
    ECR_COMMAND="ecr-public"
fi

if [ -n "${ORB_STR_PROFILE_NAME}" ]; then
    set -- "$@" --profile "${ORB_STR_PROFILE_NAME}"
fi

if [ -f "$HOME/.docker/config.json" ] && grep "${ORB_VAL_ACCOUNT_URL}" < ~/.docker/config.json > /dev/null 2>&1 ; then
    echo "Credential helper is already installed"
else
    docker logout "${ORB_VAL_ACCOUNT_URL}"    
    aws "${ECR_COMMAND}" get-login-password --region "${ORB_STR_REGION}" "$@" | docker login --username AWS --password-stdin "${ORB_VAL_ACCOUNT_URL}"
fi
