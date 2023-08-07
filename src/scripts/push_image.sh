#!/bin/bash
ORB_STR_REPO="$(circleci env subst "${ORB_STR_REPO}")"
ORB_STR_TAG="$(circleci env subst "${ORB_STR_TAG}")"
ORB_STR_REGION="$(circleci env subst "${ORB_STR_REGION}")"
ORB_VAL_ACCOUNT_URL="${!ORB_STR_ACCOUNT_ID}.dkr.ecr.${ORB_STR_REGION}.${ORB_STR_AWS_DOMAIN}"
ORB_STR_PUBLIC_REGISTRY_ALIAS="$(circleci env subst "${ORB_STR_PUBLIC_REGISTRY_ALIAS}")"

if [ -z "${!ORB_STR_ACCOUNT_ID}" ]; then
  echo "The registry ID is not found. Please add the registry ID as an environment variable in CicleCI before continuing."
  exit 1
fi

if [ "${ORB_BOOL_PUBLIC_REGISTRY}" == "1" ]; then
  ORB_VAL_ACCOUNT_URL="public.ecr.aws/${ORB_STR_PUBLIC_REGISTRY_ALIAS}"
fi

IFS="," read -ra DOCKER_TAGS <<< "${ORB_STR_TAG}"
for tag in "${DOCKER_TAGS[@]}"; do
    docker push "${ORB_VAL_ACCOUNT_URL}/${ORB_STR_REPO}:${tag}"
done
