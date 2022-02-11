#!/bin/bash
REPO=$(eval echo "${PARAM_REPO}")
SOURCE_TAG=$(eval echo "${PARAM_SOURCE_TAG}")
TARGET_TAG=$(eval echo "${PARAM_TARGET_TAG}")

# pull the image manifest from ECR
MANIFEST=$(aws ecr batch-get-image --repository-name "${REPO}" --image-ids imageTag="${SOURCE_TAG}" --query 'images[].imageManifest' --output text)
IFS="," read -ra ECR_TAGS <<< "${TARGET_TAG}"
for tag in "${ECR_TAGS[@]}"; do
    aws ecr put-image --repository-name "${REPO}" --image-tag "${tag}" --image-manifest "${MANIFEST}"
done
