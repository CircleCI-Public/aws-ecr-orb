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
fi

if [ -f "$HOME/.docker/config.json" ] && grep "${AWS_ECR_VAL_ACCOUNT_URL}" < ~/.docker/config.json > /dev/null 2>&1 ; then
    echo "Credential helper is already installed"
fi

Configure_config.json(){
    echo "Configuring config.json..."
    CONFIG_FILE="$HOME/.docker/config.json"
    mkdir -p "$(dirname "${CONFIG_FILE}")"
    cat > "${CONFIG_FILE}" << EOF
    {
        "credHelpers": {
            "${AWS_ECR_VAL_ACCOUNT_URL}": "ecr-login"
        }
    }
EOF
}

Install_AWS_ECR_Credential_Helper(){
    echo "Installing AWS ECR Credential Helper..."
    if [[ "$SYS_ENV_PLATFORM" = "linux" ]]; then
        $SUDO apt update
        $SUDO apt install amazon-ecr-credential-helper
        Configure_config.json
    elif [[ "$SYS_ENV_PLATFORM" = "macos" ]]; then
        brew install docker-credential-helper-ecr
        Configure_config.json
    else
        docker logout "${AWS_ECR_VAL_ACCOUNT_URL}"
        aws "${ECR_COMMAND}" get-login-password --region "${AWS_ECR_EVAL_REGION}" --profile "${AWS_ECR_EVAL_PROFILE_NAME}" | docker login --username AWS --password-stdin "${AWS_ECR_VAL_ACCOUNT_URL}"
    fi
}

Install_AWS_ECR_Credential_Helper