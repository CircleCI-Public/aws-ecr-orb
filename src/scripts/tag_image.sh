#!/bin/bash
AWS_ECR_EVAL_REPO="$(eval echo "${AWS_ECR_STR_REPO}")"
AWS_ECR_EVAL_SOURCE_TAG="$(eval echo "${AWS_ECR_STR_SOURCE_TAG}")"
AWS_ECR_EVAL_TARGET_TAG="$(eval echo "${AWS_ECR_STR_TARGET_TAG}")"
AWS_ECR_EVAL_AWS_PROFILE="$(eval echo "${AWS_ECR_STR_AWS_PROFILE}")"
AWS_ECR_STR_MEDIA_TYPE="$(eval echo "${AWS_ECR_STR_MEDIA_TYPE}")"
# pull the image manifest from ECR
set -x
MANIFEST="$(aws ecr batch-get-image --repository-name "${AWS_ECR_EVAL_REPO}" --image-ids imageTag="${AWS_ECR_EVAL_SOURCE_TAG}" --query 'images[].imageManifest' --output text --profile "${AWS_ECR_EVAL_AWS_PROFILE}")"
# only list images when needed
if [ "${AWS_ECR_BOOL_SKIP_WHEN_TAGS_EXIST}" -eq 1 ]; then
    EXISTING_TAGS="$(aws ecr list-images --repository-name "${AWS_ECR_EVAL_REPO}" --filter "tagStatus=TAGGED" --profile "${AWS_ECR_EVAL_AWS_PROFILE}")"
fi
IFS="," read -ra ECR_TAGS <<<"${AWS_ECR_EVAL_TARGET_TAG}"

if [ -n "$AWS_ECR_STR_MEDIA_TYPE" ]; then
    MEDIA_TYPE="--image-manifest-media-type $AWS_ECR_STR_MEDIA_TYPE"
fi

for tag in "${ECR_TAGS[@]}"; do
    # if skip_when_tags_exist is true
    if [ "${AWS_ECR_BOOL_SKIP_WHEN_TAGS_EXIST}" -eq 1 ]; then
        # tag image if tag does not exist
        if ! echo "${EXISTING_TAGS}" | grep "${tag}"; then
            aws ecr put-image --repository-name "${AWS_ECR_EVAL_REPO}" --image-tag "${tag}" --image-manifest "${MANIFEST}" "$MEDIA_TYPE" --profile "${AWS_ECR_EVAL_AWS_PROFILE}"
        else
            echo "Tag \"${tag}\" already exists and will be skipped."
        fi
    # tag image when skip_when_tags_exist is false
    else
        aws ecr put-image --repository-name "${AWS_ECR_EVAL_REPO}" --image-tag "${tag}" --image-manifest "${MANIFEST}" "$MEDIA_TYPE" --profile "${AWS_ECR_EVAL_AWS_PROFILE}"
    fi
done
set +x
