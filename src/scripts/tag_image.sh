#!/bin/bash
ORB_STR_REPO="$(circleci env subst "${ORB_STR_REPO}")"
ORB_STR_SOURCE_TAG="$(circleci env subst "${ORB_STR_SOURCE_TAG}")"
ORB_STR_TARGET_TAG="$(circleci env subst "${ORB_STR_TARGET_TAG}")"

# pull the image manifest from ECR
MANIFEST="$(aws ecr batch-get-image --repository-name "${ORB_STR_REPO}" --image-ids imageTag="${ORB_STR_SOURCE_TAG}" --query 'images[].imageManifest' --output text)"
IFS="," read -ra ECR_TAGS <<<"${ORB_STR_TARGET_TAG}"
for tag in "${ECR_TAGS[@]}"; do
    aws ecr put-image --repository-name "${ORB_STR_REPO}" --image-tag "${tag}" --image-manifest "${MANIFEST}"
done
