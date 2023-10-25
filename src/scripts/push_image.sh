#!/bin/bash
ORB_STR_REPO="$(eval echo "${ORB_STR_REPO}")"
ORB_STR_TAG="$(eval echo "${ORB_STR_TAG}")"
ORB_STR_REGION="$(eval echo "${ORB_STR_REGION}")"
ORB_STR_ACCOUNT_ID="$(eval echo "${ORB_STR_ACCOUNT_ID}")"
ORB_VAL_ACCOUNT_URL="${ORB_STR_ACCOUNT_ID}.dkr.ecr.${ORB_STR_REGION}.${ORB_STR_AWS_DOMAIN}"
ORB_STR_PUBLIC_REGISTRY_ALIAS="$(eval echo "${ORB_STR_PUBLIC_REGISTRY_ALIAS}")"

if [ -z "${ORB_STR_ACCOUNT_ID}" ]; then
  echo "The account ID is not found. Please add the account ID before continuing."
  exit 1
fi

if [ "${ORB_BOOL_PUBLIC_REGISTRY}" == "1" ]; then
  ORB_VAL_ACCOUNT_URL="public.ecr.aws/${ORB_STR_PUBLIC_REGISTRY_ALIAS}"
fi

IFS="," read -ra DOCKER_TAGS <<< "${ORB_STR_TAG}"
for tag in "${DOCKER_TAGS[@]}"; do
    docker push "${ORB_VAL_ACCOUNT_URL}/${ORB_STR_REPO}:${tag}"
done
