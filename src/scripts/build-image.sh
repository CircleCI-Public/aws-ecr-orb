#!/bin/bash
ACCOUNT_URL=$(eval echo "\$$PARAM_ACCOUNT_URL")
TAG=$(eval echo "$PARAM_TAG")
SKIP_WHEN_TAGS_EXIST=$(eval echo "$PARAM_SKIP_WHEN_TAGS_EXIST")
REPO=$(eval echo "$PARAM_REPO")
EXTRA_BUILD_ARGS=$(eval echo "$PARAM_EXTRA_BUILD_ARGS")
FILE_PATH=$(eval echo "$PARAM_PATH")
DOCKERFILE=$(eval echo "$PARAM_PATH")
PROFILE_NAME=$(eval echo "$PARAM_PROFILE_NAME")
ACCOUNT_ID=$(eval echo "\$$PARAM_ACCOUNT_ID")
number_of_tags_in_ecr=0
# echo "Registry ID: $registry_id" >> test.txt
docker_tag_args=""
IFS="," read -ra DOCKER_TAGS <<< "${TAG}"
# echo "Docker tags: $DOCKER_TAGS" >>test.txt
for tag in "${DOCKER_TAGS[@]}"; do
  if [ "${SKIP_WHEN_TAGS_EXIST}" = "true" ]; then
    docker_tag_exists_in_ecr=$(aws ecr describe-images --profile "${PROFILE_NAME}" --registry-id "${ACCOUNT_ID}" --repository-name "${REPO}" --query "contains(imageDetails[].imageTags[], '$tag')")
    if [ "${docker_tag_exists_in_ecr}" = "true" ]; then
      docker pull "${ACCOUNT_URL}/${REPO}:${tag}"
      let "number_of_tags_in_ecr+=1"
    fi
  fi
  docker_tag_args="${docker_tag_args} -t ${ACCOUNT_URL}/$REPO:$tag"
# echo "Docker tag args: $docker_tag_args" >> test.txt
done
if [ "${SKIP_WHEN_TAGS_EXIST}" = "false" ] || [ "${SKIP_WHEN_TAGS_EXIST}" = "true" -a ${number_of_tags_in_ecr} -lt ${#DOCKER_TAGS[@]} ]; then    
    if [ -n "$EXTRA_BUILD_ARGS" ]; then
        echo "It gets to this if block"
        set -- "$@" "${EXTRA_BUILD_ARG}"
    echo "$@"
    fi
    set -- "$@" -f "${PATH}/${DOCKERFILE} $docker_tag_args ${PATH}"
    echo "$@"
    set -x
    docker build "$@"
fi
