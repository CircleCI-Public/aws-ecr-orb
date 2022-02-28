#!/bin/bash
TAG=$(eval echo "$PARAM_TAG")
SKIP_WHEN_TAGS_EXIST=$(eval echo "$PARAM_SKIP_WHEN_TAGS_EXIST")
REPO=$(eval echo "${PARAM_REPO}")
EXTRA_BUILD_ARGS=$(eval echo "${PARAM_EXTRA_BUILD_ARGS}")
FILE_PATH=$(eval echo "${PARAM_PATH}")
DOCKERFILE=$(eval echo "${PARAM_DOCKERFILE}")
PROFILE_NAME=$(eval echo "${PARAM_PROFILE_NAME}")
ACCOUNT_ID=$(eval echo "\$${PARAM_ACCOUNT_ID}")
REGION=$(eval echo "\$${PARAM_REGION}")
# REGION=$(eval echo "\$${AWS_DEFAULT_REGION}")
PLATFORM=$(eval echo "${PARAM_PLATFORM}")
PUBLIC_REGISTRY=$(eval echo "${PARAM_PUBLIC_REGISTRY}")
PUSH_IMAGE=$(eval echo "${PARAM_PUSH_IMAGE}")

ACCOUNT_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
number_of_tags_in_ecr=0
docker_tag_args=""
ECR_COMMAND="ecr"

if [ "$PUBLIC_REGISTRY" == "1" ]; then
    REGION="us-east-1"
    ECR_COMMAND="ecr-public"
    ACCOUNT_URL="public.ecr.aws/${ACCOUNT_ID}"
fi

IFS="," read -ra DOCKER_TAGS <<< "${TAG}"
for tag in "${DOCKER_TAGS[@]}"; do
  if [ "${SKIP_WHEN_TAGS_EXIST}" = "1" ]; then
      docker_tag_exists_in_ecr=$(aws "${ECR_COMMAND}" describe-images --profile "${PROFILE_NAME}" --registry-id "${ACCOUNT_ID}" --region "${REGION}" --repository-name "${REPO}" --query "contains(imageDetails[].imageTags[], '${tag}')")
    if [ "${docker_tag_exists_in_ecr}" = "1" ]; then
      docker pull "${ACCOUNT_URL}/${REPO}:${tag}"
      let "number_of_tags_in_ecr+=1"
    fi
  fi
  docker_tag_args="${docker_tag_args} -t ${ACCOUNT_URL}/${REPO}:${tag}"
done
echo "$docker_tag_args" >> test.txt
if [ "${SKIP_WHEN_TAGS_EXIST}" = "0" ] || [ "${SKIP_WHEN_TAGS_EXIST}" = "1" -a ${number_of_tags_in_ecr} -lt ${#DOCKER_TAGS[@]} ]; then
    if [ "$PUSH_IMAGE" == "1" ]; then
      set -- "$@" --push
    fi 
    if [ -n "$EXTRA_BUILD_ARGS" ]; then
       set -- "$@" "${EXTRA_BUILD_ARGS}"
    fi

    docker buildx build \
    -f "${FILE_PATH}"/"${DOCKERFILE}" \
    ${docker_tag_args} \
    --platform "${PLATFORM}" \
    --progress plain \
    "$@" \
    "${FILE_PATH}" 
fi
