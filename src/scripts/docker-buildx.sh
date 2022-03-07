#!/bin/bash
REPO=$(eval echo "${PARAM_REPO}")
REGION=$(eval echo "${PARAM_REGION}")
TAG=$(eval echo "${PARAM_TAG}")
ACCOUNT_URL="${!PARAM_REGISTRY_ID}.dkr.ecr.${REGION}.amazonaws.com"
ECR_COMMAND="ecr"
number_of_tags_in_ecr=0
docker_tag_args=""

if [ "$PARAM_PUBLIC_REGISTRY" == "1" ]; then
    ECR_COMMAND="ecr-public"
    ACCOUNT_URL="public.ecr.aws/${!PARAM_REGISTRY_ID}"
fi

IFS="," read -ra DOCKER_TAGS <<< "${TAG}"
for tag in "${DOCKER_TAGS[@]}"; do
  if [ "${PARAM_SKIP_WHEN_TAGS_EXIST}" = "1" ]; then
      docker_tag_exists_in_ecr=$(aws "${ECR_COMMAND}" describe-images --profile "${PARAM_PROFILE_NAME}" --registry-id "${!PARAM_REGISTRY_ID}" --region "${REGION}" --repository-name "${REPO}" --query "contains(imageDetails[].imageTags[], '${tag}')")
    if [ "${docker_tag_exists_in_ecr}" = "1" ]; then
      docker pull "${ACCOUNT_URL}/${REPO}:${tag}"
      let "number_of_tags_in_ecr+=1"
    fi
  fi
  docker_tag_args="${docker_tag_args} -t ${ACCOUNT_URL}/${REPO}:${tag}"
  echo "docker tag args ${docker_tag_args}" >> test.txt
done

if [ "${PARAM_SKIP_WHEN_TAGS_EXIST}" = "0" ] || [ "${PARAM_SKIP_WHEN_TAGS_EXIST}" = "1" -a ${number_of_tags_in_ecr} -lt ${#DOCKER_TAGS[@]} ]; then
    if [ "$PARAM_PUSH_IMAGE" == "1" ]; then
      set -- "$@" --push
    fi

    if [ -n "$PARAM_EXTRA_BUILD_ARGS" ]; then
       set -- "$@" "${PARAM_EXTRA_BUILD_ARGS}"
    fi
    docker buildx create --name docker-multiarch --platform linux/386,linux/amd64,linux/arm/v5,linux/arm/v6,linux/arm/v7,linux/arm64,linux/mips64le,linux/ppc64le,linux/riscv64,linux/s390x \
    docker buildx inspect --builder docker-multiarch --bootstrap \
    docker buildx use docker-multiarch \
    docker buildx build \
    -f "${PARAM_PATH}"/"${PARAM_DOCKERFILE}" \
    ${docker_tag_args} \
    --platform "${PARAM_PLATFORM}" \
    --progress plain \
    "$@" \
    "${PARAM_PATH}" 
fi
