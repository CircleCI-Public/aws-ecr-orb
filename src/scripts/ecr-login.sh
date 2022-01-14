#!/bin/bash
ACCOUNT_URL=$(eval echo "\$$PARAM_ACCOUNT_URL")
REGION=$(eval echo "\$${PARAM_REGION}")
PROFILE_NAME=$(eval echo "${PARAM_PROFILE_NAME}")
aws ecr get-login-password --region $"${REGION}" --profile "${PROFILE_NAME}" | docker login --username AWS --password-stdin $"${ACCOUNT_URL}"
