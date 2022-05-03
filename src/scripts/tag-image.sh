#!/bin/bash
PARAM_REPO=$(eval echo "${PARAM_REPO}")
PARAM_SOURCE_TAG=$(eval echo "${PARAM_SOURCE_TAG}")
PARAM_TARGET_TAG=$(eval echo "${PARAM_TARGET_TAG}")

# pull the image manifest from ECR
MANIFEST=$(aws ecr batch-get-image --repository-name "${PARAM_REPO}" --image-ids imageTag="${PARAM_SOURCE_TAG}" --query 'images[].imageManifest' --output text)
IFS="," read -ra ECR_TAGS <<<"${PARAM_TARGET_TAG}"
for tag in "${ECR_TAGS[@]}"; do
    aws ecr put-image --repository-name "${PARAM_REPO}" --image-tag "${tag}" --image-manifest "${MANIFEST}"
done
