#!/bin/bash
ORB_EVAL_REGION="$(eval echo "${ORB_STR_REGION}")"
ORB_EVAL_REPO="$(eval echo "${ORB_STR_REPO}")"
ORB_EVAL_TAG="$(eval echo "${ORB_STR_TAG}")"
ORB_EVAL_PATH="$(eval echo "${ORB_EVAL_PATH}")"
ORB_STR_AWS_DOMAIN="$(echo "${ORB_STR_AWS_DOMAIN}" | circleci env subst)"
ORB_EVAL_ACCOUNT_ID="$(eval echo "${ORB_STR_ACCOUNT_ID}")"
ORB_VAL_ACCOUNT_URL="${ORB_EVAL_ACCOUNT_ID}.dkr.ecr.${ORB_EVAL_REGION}.${ORB_STR_AWS_DOMAIN}"
ORB_EVAL_PUBLIC_REGISTRY_ALIAS="$(eval echo "${ORB_STR_PUBLIC_REGISTRY_ALIAS}")"
ORB_STR_EXTRA_BUILD_ARGS="$(echo "${ORB_STR_EXTRA_BUILD_ARGS}" | circleci env subst)"
ORB_EVAL_BUILD_PATH="$(eval echo "${ORB_EVAL_BUILD_PATH}")"
ORB_EVAL_DOCKERFILE="$(eval echo "${ORB_STR_DOCKERFILE}")"
ORB_EVAL_PROFILE_NAME="$(eval echo "${ORB_STR_PROFILE_NAME}")"
ORB_EVAL_PLATFORM="$(eval echo "${ORB_STR_PLATFORM}")"
ORB_EVAL_LIFECYCLE_POLICY_PATH="$(eval echo "${ORB_STR_LIFECYCLE_POLICY_PATH}")"

ECR_COMMAND="ecr"
number_of_tags_in_ecr=0

IFS=', ' read -ra platform <<<"${ORB_EVAL_PLATFORM}"
number_of_platforms="${#platform[@]}"

if [ -z "${ORB_EVAL_ACCOUNT_ID}" ]; then
  echo "The account ID is not found. Please add the account ID before continuing."
  exit 1
fi

if [ "${ORB_BOOL_PUBLIC_REGISTRY}" -eq "1" ]; then
  ECR_COMMAND="ecr-public"
  ORB_VAL_ACCOUNT_URL="public.ecr.aws/${ORB_EVAL_PUBLIC_REGISTRY_ALIAS}"
fi

IFS="," read -ra DOCKER_TAGS <<<"${ORB_EVAL_TAG}"
for tag in "${DOCKER_TAGS[@]}"; do
  if [ "${ORB_BOOL_SKIP_WHEN_TAGS_EXIST}" -eq "1" ] || [ "${ORB_BOOL_SKIP_WHEN_TAGS_EXIST}" = "true" ]; then
    docker_tag_exists_in_ecr=$(aws "${ECR_COMMAND}" describe-images --profile "${ORB_EVAL_PROFILE_NAME}" --registry-id "${ORB_EVAL_ACCOUNT_ID}" --region "${ORB_EVAL_REGION}" --repository-name "${ORB_EVAL_REPO}" --query "contains(imageDetails[].imageTags[], '${tag}')")
    if [ "${docker_tag_exists_in_ecr}" = "true" ]; then
      docker pull "${ORB_VAL_ACCOUNT_URL}/${ORB_EVAL_REPO}:${tag}"
      number_of_tags_in_ecr=$((number_of_tags_in_ecr += 1))
    fi
  fi
  docker_tag_args="${docker_tag_args} -t ${ORB_VAL_ACCOUNT_URL}/${ORB_EVAL_REPO}:${tag}"
done

if [ "${ORB_BOOL_SKIP_WHEN_TAGS_EXIST}" -eq "0" ] || [[ "${ORB_BOOL_SKIP_WHEN_TAGS_EXIST}" -eq "1" && ${number_of_tags_in_ecr} -lt ${#DOCKER_TAGS[@]} ]]; then
  if [ "${ORB_BOOL_PUSH_IMAGE}" -eq "1" ]; then
    set -- "$@" --push

    if [ -n "${ORB_EVAL_LIFECYCLE_POLICY_PATH}" ]; then
      aws ecr put-lifecycle-policy \
        --profile "${ORB_EVAL_PROFILE_NAME}" \
        --repository-name "${ORB_EVAL_REPO}" \
        --lifecycle-policy-text "file://${ORB_EVAL_LIFECYCLE_POLICY_PATH}"
    fi

  elif [ "${ORB_BOOL_PUSH_IMAGE}" -eq "0" ] && [ "${number_of_platforms}" -le 1 ];then
    set -- "$@" --load
  fi

  if [ "${number_of_platforms}" -gt 1 ]; then
    # In order to build multi-architecture images, a context with binfmt installed must be used.

    if ! docker context ls | grep builder; then
      # We need to skip the creation of the builder context if it's already present
      # otherwise the command will fail when called more than once in the same job.
      docker context create builder
      docker run --privileged --rm tonistiigi/binfmt --install all
      docker --context builder buildx create --name DLC_builder --use
    fi
    context_args="--context builder"
  # if no builder instance is currently used, create one
  elif ! docker buildx inspect | grep -q "default * docker"; then
    docker buildx create --name DLC_builder --use
  fi

set -x
  docker \
    ${context_args:+$context_args} \
    buildx build \
    -f "${ORB_EVAL_PATH}"/"${ORB_EVAL_DOCKERFILE}" \
    ${docker_tag_args:+$docker_tag_args} \
    --platform "${ORB_EVAL_PLATFORM}" \
    --progress plain \
    ${ORB_STR_EXTRA_BUILD_ARGS:+$ORB_STR_EXTRA_BUILD_ARGS} \
    "$@" \
    "${ORB_EVAL_BUILD_PATH}"
set +x

fi
