#!/bin/bash
ORB_EVAL_REGION=$(eval echo "${ORB_EVAL_REGION}")
ORB_EVAL_ACCOUNT_URL="${!ORB_EVAL_REGISTRY_ID}.dkr.ecr.${ORB_EVAL_REGION}.amazonaws.com"
ECR_COMMAND="ecr"

if [ "$ORB_EVAL_PUBLIC_REGISTRY" == "1" ]; then
    ORB_EVAL_REGION="us-east-1"
    ORB_EVAL_ACCOUNT_URL="public.ecr.aws"
    ECR_COMMAND="ecr-public"
fi

if [ -n "${ORB_EVAL_PROFILE_NAME}" ]; then
    set -- "$@" --profile "${ORB_EVAL_PROFILE_NAME}"
fi

#Shellcheck disable=SC2002
if [ -f "$HOME/.docker/config.json" ] && cat ~/.docker/config.json | grep "${ORB_EVAL_ACCOUNT_URL}" > /dev/null 2>&1 ; then
    echo "Credential helper is already installed"
else
    aws "${ECR_COMMAND}" get-login-password --region "${ORB_EVAL_REGION}" "$@" | docker login --username AWS --password-stdin "${ORB_EVAL_ACCOUNT_URL}"
fi
