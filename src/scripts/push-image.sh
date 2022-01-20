#!/bin/bash
REGION=$(eval echo "\$${PARAM_REGION}")
ACCOUNT_ID=$(eval echo "\$${PARAM_ACCOUNT_ID}")
REPO=$(eval echo "${PARAM_REPO}")
TAG=$(eval echo "${PARAM_TAG}")
IFS="," read -ra DOCKER_TAGS <<< "${TAG}"
ACCOUNT_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
for tag in "${DOCKER_TAGS[@]}"; do
    docker push "${ACCOUNT_URL}/${REPO}:${tag}"
done
