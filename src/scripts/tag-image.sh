#!/bin/bash
ORB_EVAL_REPO=$(eval echo "${ORB_EVAL_REPO}")
ORB_EVAL_SOURCE_TAG=$(eval echo "${ORB_EVAL_SOURCE_TAG}")
ORB_EVAL_TARGET_TAG=$(eval echo "${ORB_EVAL_TARGET_TAG}")

# pull the image manifest from ECR
MANIFEST=$(aws ecr batch-get-image --repository-name "${ORB_EVAL_REPO}" --image-ids imageTag="${ORB_EVAL_SOURCE_TAG}" --query 'images[].imageManifest' --output text)
IFS="," read -ra ECR_TAGS <<<"${ORB_EVAL_TARGET_TAG}"
for tag in "${ECR_TAGS[@]}"; do
    aws ecr put-image --repository-name "${ORB_EVAL_REPO}" --image-tag "${tag}" --image-manifest "${MANIFEST}"
done
