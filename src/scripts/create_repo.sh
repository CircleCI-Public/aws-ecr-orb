#!/bin/bash
AWS_ECR_EVAL_REGION="$(eval echo "${AWS_ECR_STR_REGION}")"
AWS_ECR_EVAL_REPO="$(eval echo "${AWS_ECR_STR_REPO}")"
AWS_ECR_EVAL_PROFILE_NAME="$(eval echo "${AWS_ECR_STR_PROFILE_NAME}")"
AWS_ECR_EVAL_ENCRYPTION_KMS_KEY="$(eval echo "${AWS_ECR_STR_ENCRYPTION_KMS_KEY}")"

if [ "$AWS_ECR_BOOL_PUBLIC_REGISTRY" == "1" ]; then
    aws ecr-public describe-repositories --profile "${AWS_ECR_EVAL_PROFILE_NAME}" --region us-east-1 --repository-names "${AWS_ECR_EVAL_REPO}" >/dev/null 2>&1 ||
        aws ecr-public create-repository --profile "${AWS_ECR_EVAL_PROFILE_NAME}" --region us-east-1 --repository-name "${AWS_ECR_EVAL_REPO}"
else

    IMAGE_SCANNING_CONFIGURATION="scanOnPush=true"
    if [ "$AWS_ECR_BOOL_REPO_SCAN_ON_PUSH" -ne "1" ]; then
      IMAGE_SCANNING_CONFIGURATION="scanOnPush=false"
    fi

    ENCRYPTION_CONFIGURATION="encryptionType=${AWS_ECR_ENUM_ENCRYPTION_TYPE}"
    if [ "$AWS_ECR_ENUM_ENCRYPTION_TYPE" == "KMS"  ]; then
      ENCRYPTION_CONFIGURATION+=",kmsKey=${AWS_ECR_EVAL_ENCRYPTION_KMS_KEY}"
    fi

    aws ecr describe-repositories \
      --profile "${AWS_ECR_EVAL_PROFILE_NAME}" \
      --region "${AWS_ECR_EVAL_REGION}" \
      --repository-names "${AWS_ECR_EVAL_REPO}" >/dev/null 2>&1 ||
        aws ecr create-repository \
          --profile "${AWS_ECR_EVAL_PROFILE_NAME}" \
          --region "${AWS_ECR_EVAL_REGION}" \
          --repository-name "${AWS_ECR_EVAL_REPO}" \
          --image-scanning-configuration "${IMAGE_SCANNING_CONFIGURATION}" \
          --encryption-configuration "${ENCRYPTION_CONFIGURATION}"
fi
