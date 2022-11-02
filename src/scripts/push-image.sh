#!/bin/bash
ORB_VAL_ACCOUNT_URL="${ORB_ENV_REGISTRY_ID}.dkr.ecr.${ORB_EVAL_REGION}.amazonaws.com"
ORB_EVAL_REPO=$(eval echo "${ORB_EVAL_REPO}")
ORB_EVAL_TAG=$(eval echo "${ORB_EVAL_TAG}")

IFS="," read -ra DOCKER_TAGS <<< "${ORB_EVAL_TAG}"
for tag in "${DOCKER_TAGS[@]}"; do
    docker push "${ORB_VAL_ACCOUNT_URL}/${ORB_EVAL_REPO}:${tag}"
done
