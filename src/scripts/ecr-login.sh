#!/bin/bash
REGION=$(eval echo "${PARAM_REGION}")
# PROFILE_NAME=$(eval echo "${PARAM_PROFILE_NAME}")
# REGISTRY_ID=$(eval echo "\$${PARAM_REGISTRY_ID}")
# PUBLIC_REGISTRY=$(eval echo "${PARAM_PUBLIC_REGISTRY}")
ACCOUNT_URL="${!PARAM_REGISTRY_ID}.dkr.ecr.${REGION}.amazonaws.com"
ECR_COMMAND="ecr"

if [ "$PARAM_PUBLIC_REGISTRY" == "1" ]; then
    REGION="us-east-1"
    ACCOUNT_URL="public.ecr.aws"
    ECR_COMMAND="ecr-public"
fi

if [ -n "${PARAM_PROFILE_NAME}" ]; then
    set -- "$@" --profile "${PARAM_PROFILE_NAME}"
fi

if [ -f ~/.docker/config.json ]; then
    echo "Credential helper is already installed"
else
    aws "${ECR_COMMAND}" get-login-password --region "${REGION}" "$@" | docker login --username AWS --password-stdin "${ACCOUNT_URL}"
fi
