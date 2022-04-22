#!/bin/bash
PARAM_REGION=$(eval echo "${PARAM_REGION}")
PARAM_REPO=$(eval echo "${PARAM_REPO}")
PARAM_TAG=$(eval echo "${PARAM_TAG}")
PARAM_ACCOUNT_URL="${!PARAM_REGISTRY_ID}.dkr.ecr.${PARAM_REGION}.amazonaws.com"
ECR_COMMAND="ecr"
number_of_tags_in_ecr=0
docker_tag_args=""

IFS="," read -ra PLATFORMS <<<"${PARAM_PLATFORM}"
arch_count=${#PLATFORMS[@]}

if [ "${PARAM_PUBLIC_REGISTRY}" == "1" ]; then
  if [ "$arch_count" -gt 1 ]; then
    echo "AWS ECR does not support multiple platforms for public registries. Please specify only one platform and try again"
    exit 1
  fi

  ECR_COMMAND="ecr-public"
  PARAM_ACCOUNT_URL="public.ecr.aws/${!PARAM_REGISTRY_ID}"
fi

IFS="," read -ra DOCKER_TAGS <<<"${PARAM_TAG}"
for tag in "${DOCKER_TAGS[@]}"; do
  if [ "${PARAM_SKIP_WHEN_TAGS_EXIST}" = "1" ]; then
    docker_tag_exists_in_ecr=$(aws "${ECR_COMMAND}" describe-images --profile "${PARAM_PROFILE_NAME}" --registry-id "${!PARAM_REGISTRY_ID}" --region "${PARAM_REGION}" --repository-name "${PARAM_REPO}" --query "contains(imageDetails[].imageTags[], '${tag}')")
    if [ "${docker_tag_exists_in_ecr}" = "1" ]; then
      docker pull "${PARAM_ACCOUNT_URL}/${PARAM_REPO}:${tag}"
      number_of_tags_in_ecr=$((number_of_tags_in_ecr += 1))
    fi
  fi
  docker_tag_args="${docker_tag_args} -t ${PARAM_ACCOUNT_URL}/${PARAM_REPO}:${tag}"
done

if [ "${PARAM_SKIP_WHEN_TAGS_EXIST}" = "0" ] || [[ "${PARAM_SKIP_WHEN_TAGS_EXIST}" = "1" && ${number_of_tags_in_ecr} -lt ${#DOCKER_TAGS[@]} ]]; then
  if [ "${PARAM_PUSH_IMAGE}" == "1" ]; then
    set -- "$@" --push

    if [ -n "${PARAM_LIFECYCLE_POLICY_PATH}" ]; then
      aws ecr put-lifecycle-policy \
        --repository-name "${PARAM_REPO}" \
        --lifecycle-policy-text "${PARAM_LIFECYCLE_POLICY_PATH}"
    fi

  else
    set -- "$@" --load
  fi

  if [ -n "$PARAM_EXTRA_BUILD_ARGS" ]; then
    set -- "$@" ${PARAM_EXTRA_BUILD_ARGS}
  fi

  if [ "${PARAM_PUBLIC_REGISTRY}" == "1" ]; then
    docker buildx build \
      -f "${PARAM_PATH}"/"${PARAM_DOCKERFILE}" \
      ${docker_tag_args} \
      --platform "${PARAM_PLATFORM}" \
      --progress plain \
      "$@" \
      "${PARAM_PATH}"
  else
    docker context create builder
    docker run --privileged --rm tonistiigi/binfmt --install all
    docker --context builder buildx create --use
    docker --context builder buildx build \
      -f "${PARAM_PATH}"/"${PARAM_DOCKERFILE}" \
      ${docker_tag_args} \
      --platform "${PARAM_PLATFORM}" \
      --progress plain \
      "$@" \
      "${PARAM_PATH}"
  fi
fi
