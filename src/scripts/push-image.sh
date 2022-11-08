#!/bin/bash
ORB_EVAL_REPO=$(eval echo "${ORB_EVAL_REPO}")
ORB_EVAL_TAG=$(eval echo "${ORB_EVAL_TAG}")
ORB_EVAL_REGION=$(eval echo "${ORB_EVAL_REGION}")
ORB_VAL_ACCOUNT_URL="${!ORB_ENV_REGISTRY_ID}.dkr.ecr.${ORB_EVAL_REGION}.amazonaws.com"
ORB_EVAL_PUBLIC_REGISTRY_ALIAS=$(eval echo "${ORB_EVAL_PUBLIC_REGISTRY_ALIAS}")

if [ "${ORB_VAL_PUBLIC_REGISTRY}" == "1" ]; then
  ORB_VAL_ACCOUNT_URL="public.ecr.aws/${ORB_EVAL_PUBLIC_REGISTRY_ALIAS}"
fi

IFS="," read -ra DOCKER_TAGS <<< "${ORB_EVAL_TAG}"
for tag in "${DOCKER_TAGS[@]}"; do
    docker push "${ORB_VAL_ACCOUNT_URL}/${ORB_EVAL_REPO}:${tag}"
done
