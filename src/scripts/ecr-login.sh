#!/bin/bash
REGION=$(eval echo "\$${PARAM_REGION}")
PROFILE_NAME=$(eval echo "${PARAM_PROFILE_NAME}")
ACCOUNT_ID=$(eval echo "\$${PARAM_ACCOUNT_ID}")
ACCOUNT_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

if [ -f ~/.docker/config.json ]; then
    echo "Credential helper installed"
else
    aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ACCOUNT_URL}"
    # aws ecr-public get-login-password --region us-east-1 --profile | docker login --username AWS --password-stdin public.ecr.aws
fi
