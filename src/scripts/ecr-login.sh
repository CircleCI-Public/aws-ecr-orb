#!/bin/bash
REGION=$(eval echo "\$${PARAM_REGION}")
PROFILE_NAME=$(eval echo "${PARAM_PROFILE_NAME}")
ACCOUNT_ID=$(eval echo "\$${PARAM_ACCOUNT_ID}")
ACCOUNT_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
echo "${ACCOUNT_URL}" > test.txt
echo "\$${AWS_ACCESS_KEY_ID}" > test.txt
echo "\$${AWS_SECRET_ACCESS_KEY}" > test.txt

aws ecr get-login-password --region "${REGION}" --profile "${PROFILE_NAME}" | docker login --username AWS --password-stdin "${ACCOUNT_URL}"
