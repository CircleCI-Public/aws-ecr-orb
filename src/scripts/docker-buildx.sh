#!/bin/bash
REGION=$(eval echo "${PARAM_REGION}")
REPO=$(eval echo "${PARAM_REPO}")
TAG=$(eval echo "$PARAM_TAG")
ACCOUNT_URL="${PARAM_REGISTRY_ID}.dkr.ecr.${REGION}.amazonaws.com"
number_of_tags_in_ecr=0
docker_tag_args=""
ECR_COMMAND="ecr"

if [ "$PARAM_PUBLIC_REGISTRY" == "1" ]; then
    ECR_COMMAND="ecr-public"
    ACCOUNT_URL="public.ecr.aws/${PARAM_REGISTRY_ID}"
fi

IFS="," read -ra DOCKER_TAGS <<< "${TAG}"
for tag in "${PARAM_DOCKER_TAGS[@]}"; do
  if [ "${PARAM_SKIP_WHEN_TAGS_EXIST}" = "1" ]; then
      docker_tag_exists_in_ecr=$(aws "${ECR_COMMAND}" describe-images --profile "${PARAM_PROFILE_NAME}" --registry-id "${PARAM_REGISTRY_ID}" --region "${REGION}" --repository-name "${REPO}" --query "contains(imageDetails[].imageTags[], '${tag}')")
    if [ "${docker_tag_exists_in_ecr}" = "1" ]; then
      docker pull "${ACCOUNT_URL}/${REPO}:${tag}"
      let "number_of_tags_in_ecr+=1"
    fi
  fi
  docker_tag_args="${docker_tag_args} -t ${ACCOUNT_URL}/${REPO}:${tag}"
done

if [ "${PARAM_SKIP_WHEN_TAGS_EXIST}" = "0" ] || [ "${PARAM_SKIP_WHEN_TAGS_EXIST}" = "1" -a ${number_of_tags_in_ecr} -lt ${#DOCKER_TAGS[@]} ]; then
    if [ "$PARAM_PUSH_IMAGE" == "1" ]; then
      set -- "$@" --push
    fi
    if [ -n "$PARAM_EXTRA_BUILD_ARGS" ]; then
       set -- "$@" "${PARAM_EXTRA_BUILD_ARGS}"
    fi

    docker buildx build \
    -f "${PARAM_PATH}"/"${PARAM_DOCKERFILE}" \
    ${docker_tag_args} \
    --platform "${PARAM_PLATFORM}" \
    --progress plain \
    "$@" \
    "${PARAM_PATH}"     
fi
