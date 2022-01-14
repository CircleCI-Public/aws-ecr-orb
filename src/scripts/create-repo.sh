#!/bin/bash
PROFILE_NAME=$(eval echo "${PARAM_PROFILE_NAME}")
REGION=$(eval echo "\$${PARAM_REGION}")
REPO=$(eval echo "${PARAM_REPO}")
REPO_SCAN_ON_PUSH=$(eval echo "${PARAM_REPO_SCAN_ON_PUSH}")

echo "${PROFILE_NAME}" >> test.txt
echo "${REGION}" >> test.txt
echo "${REPO}" >> test.txt
echo "${REPO_SCAN_ON_PUSH}" >> test.txt
echo "$REPO_SCAN_ON_PUSH" >> test.txt


aws ecr describe-repositories --profile "${PROFILE_NAME}" --region "${REGION}" --repository-names "${REPO}" > /dev/null 2>&1 || \
if [ "$REPO_SCAN_ON_PUSH" == "1" ]; then
    aws ecr create-repository --profile "${PROFILE_NAME}" --region "${REGION}" --repository-name "${REPO}" --image-scanning-configuration scanOnPush=true
else
    aws ecr create-repository --profile "${PROFILE_NAME}" --region "${REGION}" --repository-name "${REPO}" --image-scanning-configuration scanOnPush=false
fi
