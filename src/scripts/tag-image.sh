#!/bin/bash
REPO=$(eval echo "${PARAM_REPO}")
SOURCE_TAG=$(eval echo "${PARAM_SOURCE_TAG}")
TARGET_TAG=$(eval echo "${PARAM_TARGET_TAG}")
PUBLIC_REGISTRY=$(eval echo "${PARAM_PUBLIC_REGISTRY}")
ECR_COMMAND="ecr"

if [ "$PUBLIC_REGISTRY" == "1" ]; then
    ECR_COMMAND="ecr-public"
fi

# pull the image manifest from ECR
MANIFEST=$(aws "${ECR_COMMAND}" batch-get-image --repository-name "${REPO}" --image-ids imageTag="${SOURCE_TAG}" --query 'images[].imageManifest' --output text)
IFS="," read -ra ECR_TAGS <<< "${TARGET_TAG}"
for tag in "${ECR_TAGS[@]}"; do
    aws "${ECR_COMMAND}" put-image --repository-name "${REPO}" --image-tag "${tag}" --image-manifest "${MANIFEST}"
done
