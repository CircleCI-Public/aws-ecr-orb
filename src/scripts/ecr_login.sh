#!/bin/bash
AWS_ECR_EVAL_REGION="$(eval echo "${AWS_ECR_STR_REGION}")"
AWS_ECR_EVAL_PROFILE_NAME="$(eval echo "${AWS_ECR_STR_PROFILE_NAME}")"
AWS_ECR_EVAL_ACCOUNT_ID="$(eval echo "${AWS_ECR_STR_ACCOUNT_ID}")"
AWS_ECR_VAL_ACCOUNT_URL="${AWS_ECR_EVAL_ACCOUNT_ID}.dkr.ecr.${AWS_ECR_EVAL_REGION}.${AWS_ECR_STR_AWS_DOMAIN}"
AWS_ECR_EVAL_PUBLIC_REGISTRY_ALIAS="$(eval echo "${AWS_ECR_STR_PUBLIC_REGISTRY_ALIAS}")"
ECR_COMMAND="ecr"

eval "$SCRIPT_UTILS"
detect_os
set_sudo

if [ -z "${AWS_ECR_EVAL_ACCOUNT_ID}" ]; then
  echo "The account ID is not found. Please add the account ID before continuing."
  exit 1
fi

if [ "$AWS_ECR_BOOL_PUBLIC_REGISTRY" == "1" ]; then
    AWS_ECR_EVAL_REGION="us-east-1"
    AWS_ECR_VAL_ACCOUNT_URL="public.ecr.aws/${AWS_ECR_EVAL_PUBLIC_REGISTRY_ALIAS}"
    ECR_COMMAND="ecr-public"
    aws "${ECR_COMMAND}" get-login-password --region "${AWS_ECR_EVAL_REGION}" --profile "${AWS_ECR_EVAL_PROFILE_NAME}" \
     | docker login --username AWS --password-stdin "${AWS_ECR_VAL_ACCOUNT_URL}"
    exit 0
fi

if [ -f "$HOME/.docker/config.json" ] && grep "${AWS_ECR_VAL_ACCOUNT_URL}" < ~/.docker/config.json > /dev/null 2>&1 ; then
    echo "Credential helper is already installed and configured"
    exit 0
fi

configure_config_json(){
    echo "Configuring config.json..."
    CONFIG_FILE="$HOME/.docker/config.json"
    mkdir -p "$(dirname "${CONFIG_FILE}")"

    jq_flag=""
    if [ ! -s "${CONFIG_FILE}" ]; then
        jq_flag="-n"
    fi

    jq ${jq_flag} --arg url "${AWS_ECR_VAL_ACCOUNT_URL}" \
      --arg helper "ecr-login" '.credHelpers[$url] = $helper' \
      "${CONFIG_FILE}" > temp.json && mv temp.json "${CONFIG_FILE}"
}

install_aws_ecr_credential_helper(){
    echo "Installing AWS ECR Credential Helper..."
    if [[ "$SYS_ENV_PLATFORM" = "linux" ]]; then
        HELPER_INSTALLED=$(dpkg --get-selections | grep amazon-ecr-credential-helper | awk '{ print $2 }')
        if [[ "$HELPER_INSTALLED" != "install" ]]; then
            $SUDO apt update
            $SUDO apt install amazon-ecr-credential-helper
        fi
        configure_config_json
    elif [[ "$SYS_ENV_PLATFORM" = "macos" ]]; then
        HELPER_INSTALLED=$(brew list -q | grep -q docker-credential-helper-ecr)
        if [[ "$HELPER_INSTALLED" -ne 0 ]]; then
            brew install docker-credential-helper-ecr
        fi
        configure_config_json
    else
        docker logout "${AWS_ECR_VAL_ACCOUNT_URL}"
        aws "${ECR_COMMAND}" get-login-password --region "${AWS_ECR_EVAL_REGION}" --profile "${AWS_ECR_EVAL_PROFILE_NAME}" | docker login --username AWS --password-stdin "${AWS_ECR_VAL_ACCOUNT_URL}"
    fi
}

install_aws_ecr_credential_helper