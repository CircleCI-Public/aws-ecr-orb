#!/bin/bash
# ORB_ENV_IMAGE_REGISTRY_USERNAME="$(echo "${ORB_ENV_IMAGE_REGISTRY_USERNAME}" | circleci env subst)"         
# ORB_ENV_IMAGE_REGISTRY_PASSWORD="$(echo "${ORB_ENV_IMAGE_REGISTRY_PASSWORD}" | circleci env subst)"         
ORB_STR_IMAGE_REGISTRY_URL="$(echo "${ORB_STR_IMAGE_REGISTRY_URL}" | circleci env subst)"

if [ -n "${ORB_STR_IMAGE_REGISTRY_URL}" ]; then
    docker login "${ORB_STR_IMAGE_REGISTRY_URL}" -u "${!ORB_ENV_IMAGE_REGISTRY_USERNAME}" "${!ORB_ENV_IMAGE_REGISTRY_PASSWORD}" -p
else
    docker login -u "${!ORB_ENV_IMAGE_REGISTRY_USERNAME}" "${!ORB_ENV_IMAGE_REGISTRY_PASSWORD}" -p
fi

            