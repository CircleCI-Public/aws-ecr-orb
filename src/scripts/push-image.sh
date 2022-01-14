#!/bin/bash
ACCOUNT_URL=$(eval echo "\$$PARAM_ACCOUNT_URL")
REPO=$(eval echo "$PARAM_REPO")
TAG=$(eval echo "$PARAM_TAG")
IFS="," read -ra DOCKER_TAGS <<< "${TAG}"
for tag in "${DOCKER_TAGS[@]}"; do
    docker push "${ACCOUNT_URL}/${REPO}:${tag}"
done
