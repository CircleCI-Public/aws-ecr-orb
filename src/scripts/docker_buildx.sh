#!/bin/bash
ORB_EVAL_REGION="$(circleci env subst "${ORB_EVAL_REGION}")"
ORB_EVAL_REPO="$(circleci env subst "${ORB_EVAL_REPO}")"
ORB_EVAL_TAG="$(circleci env subst "${ORB_EVAL_TAG}")"
ORB_EVAL_PATH="$(circleci env subst "${ORB_EVAL_PATH}")"
ORB_VAL_ACCOUNT_URL="${!ORB_ENV_REGISTRY_ID}.dkr.ecr.${ORB_EVAL_REGION}.amazonaws.com"
ORB_EVAL_PUBLIC_REGISTRY_ALIAS="$(circleci env subst "${ORB_EVAL_PUBLIC_REGISTRY_ALIAS}")"
ORB_EVAL_EXTRA_BUILD_ARGS="$(echo "${ORB_EVAL_EXTRA_BUILD_ARGS}" | circleci env subst)"
ORB_EVAL_BUILD_PATH="$(circleci env subst "${ORB_EVAL_BUILD_PATH}")"
ORB_EVAL_DOCKERFILE="$(circleci env subst "${ORB_EVAL_DOCKERFILE}")"
ORB_EVAL_PROFILE_NAME="$(circleci env subst "${ORB_EVAL_PROFILE_NAME}")"
ORB_EVAL_PLATFORM="$(circleci env subst "${ORB_EVAL_PLATFORM}")"
ORB_EVAL_LIFECYCLE_POLICY_PATH="$(circleci env subst "${ORB_EVAL_LIFECYCLE_POLICY_PATH}")"

ECR_COMMAND="ecr"
number_of_tags_in_ecr=0

IFS=', ' read -ra platform <<<"${ORB_EVAL_PLATFORM}"
number_of_platforms="${#platform[@]}"

if [ -z "${!ORB_ENV_REGISTRY_ID}" ]; then
  echo "The registry ID is not found. Please add the registry ID as an environment variable in CicleCI before continuing."
  exit 1
fi

if [ "${ORB_VAL_PUBLIC_REGISTRY}" == "1" ]; then
  ECR_COMMAND="ecr-public"
  ORB_VAL_ACCOUNT_URL="public.ecr.aws/${ORB_EVAL_PUBLIC_REGISTRY_ALIAS}"
fi

IFS="," read -ra DOCKER_TAGS <<<"${ORB_EVAL_TAG}"
for tag in "${DOCKER_TAGS[@]}"; do
  if [ "${ORB_VAL_SKIP_WHEN_TAGS_EXIST}" = "1" ] || [ "${ORB_VAL_SKIP_WHEN_TAGS_EXIST}" = "true" ]; then
    docker_tag_exists_in_ecr=$(aws "${ECR_COMMAND}" describe-images --profile "${ORB_EVAL_PROFILE_NAME}" --registry-id "${!ORB_ENV_REGISTRY_ID}" --region "${ORB_EVAL_REGION}" --repository-name "${ORB_EVAL_REPO}" --query "contains(imageDetails[].imageTags[], '${tag}')")
    if [ "${docker_tag_exists_in_ecr}" = "true" ]; then
      docker pull "${ORB_VAL_ACCOUNT_URL}/${ORB_EVAL_REPO}:${tag}"
      number_of_tags_in_ecr=$((number_of_tags_in_ecr += 1))
    fi
  fi
  docker_tag_args="${docker_tag_args} -t ${ORB_VAL_ACCOUNT_URL}/${ORB_EVAL_REPO}:${tag}"
done

if [ "${ORB_VAL_SKIP_WHEN_TAGS_EXIST}" = "0" ] || [[ "${ORB_VAL_SKIP_WHEN_TAGS_EXIST}" = "1" && ${number_of_tags_in_ecr} -lt ${#DOCKER_TAGS[@]} ]]; then
  if [ "${ORB_VAL_PUSH_IMAGE}" == "1" ]; then
    set -- "$@" --push

    if [ -n "${ORB_EVAL_LIFECYCLE_POLICY_PATH}" ]; then
      aws ecr put-lifecycle-policy \
        --repository-name "${ORB_EVAL_REPO}" \
        --lifecycle-policy-text "file://${ORB_EVAL_LIFECYCLE_POLICY_PATH}"
    fi

  else
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
  fi 

set -x
  docker \
    ${context_args:+$context_args} \
    buildx build \
    -f "${ORB_EVAL_PATH}"/"${ORB_EVAL_DOCKERFILE}" \
    ${docker_tag_args:+$docker_tag_args} \
    --platform "${ORB_EVAL_PLATFORM}" \
    --progress plain \
    ${ORB_EVAL_EXTRA_BUILD_ARGS:+$ORB_EVAL_EXTRA_BUILD_ARGS} \
    "$@" \
    "${ORB_EVAL_BUILD_PATH}"
set +x
  
fi