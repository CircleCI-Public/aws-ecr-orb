#!/bin/bash
PARAM_REGION=$(eval echo "${PARAM_REGION}")
PARAM_ACCOUNT_URL="${!PARAM_REGISTRY_ID}.dkr.ecr.${PARAM_REGION}.amazonaws.com"
ECR_COMMAND="ecr"

if [ "$PARAM_PUBLIC_REGISTRY" == "1" ]; then
    PARAM_REGION="us-east-1"
    PARAM_ACCOUNT_URL="public.ecr.aws"
    ECR_COMMAND="ecr-public"
fi

if [ -n "${PARAM_PROFILE_NAME}" ]; then
    set -- "$@" --profile "${PARAM_PROFILE_NAME}"
    echo "$@" >> test.txt
fi

if [ -f ~/.docker/config.json ]; then
    echo "Credential helper is already installed"
else
    echo "aws \"${ECR_COMMAND}\" get-login-password --region \"${PARAM_REGION}\" \"$@\" | docker login --username AWS --password-stdin \"${PARAM_ACCOUNT_URL}\"" >> test.txt
    aws "${ECR_COMMAND}" get-login-password --region "${PARAM_REGION}" "$@" | docker login --username AWS --password-stdin "${PARAM_ACCOUNT_URL}"
fi

