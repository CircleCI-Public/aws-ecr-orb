#!/bin/bash
# Use this tool to assist in migrating your Orb Development Kit pipeline.

verify_run() {
  # Ensure .circleci/config.yml exists
  if [ ! -f .circleci/config.yml ]; then
    echo "No .circleci/config.yml found"
    echo "This does not appear to be the root of a CircleCI project"
    exit 1
  fi
}

backup_contents() {
  # Backup the existing files in .circleci/
  for file in .circleci/*; do
    if [ -f "$file" ]; then
      mv "$file" "$file.bak"
    fi
  done
}

download_template() {
  ORB_TEMPLATE_TAG_LIST=$(curl --request GET \
    --url https://api.github.com/repos/CircleCI-Public/Orb-Template/tags \
    --header 'Accept: application/vnd.github.v3+json' | jq -r '.[].name' | grep -v '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -Vr)
  ORB_TEMPLATE_VERSION=$(echo "$ORB_TEMPLATE_TAG_LIST" | head -n 1)
  ORB_TEMPLATE_DOWNLOAD_URL="https://github.com/CircleCI-Public/Orb-Template/archive/refs/tags/${ORB_TEMPLATE_VERSION}.tar.gz"
  ORB_TEMP_DIR=$(mktemp -d)

  curl -Ls "$ORB_TEMPLATE_DOWNLOAD_URL" -o "$ORB_TEMP_DIR/orb-template.tar.gz"
  tar -xzf "$ORB_TEMP_DIR/orb-template.tar.gz" -C "$ORB_TEMP_DIR" --strip-components 1
  cp -r "${ORB_TEMP_DIR}/.circleci/." .circleci/
}

copy_custom_components() {
  ORIGINAL_EXECUTORS=$(yq '.executors' .circleci/config.yml.bak)
  ORIGINAL_JOBS=$(yq '.jobs' .circleci/config.yml.bak)
  ORIGINAL_COMMANDS=$(yq '.commands' .circleci/config.yml.bak)
  export ORIGINAL_EXECUTORS
  export ORIGINAL_JOBS
  export ORIGINAL_COMMANDS
  if [[ -n "$ORIGINAL_EXECUTORS" && ! "$ORIGINAL_EXECUTORS" == "null" ]]; then
    yq -i '. += {"executors": env(ORIGINAL_EXECUTORS)}' .circleci/test-deploy.yml
  fi
  if [[ -n "$ORIGINAL_JOBS" && ! "$ORIGINAL_JOBS" == "null" ]]; then
    yq -i '. += {"jobs": env(ORIGINAL_JOBS)}' .circleci/test-deploy.yml
  fi
  if [[ -n "$ORIGINAL_COMMANDS" && ! "$ORIGINAL_COMMANDS" == "null" ]]; then
    yq -i '. += {"commands": env(ORIGINAL_COMMANDS)}' .circleci/test-deploy.yml
  fi
}

user_input() {
  read -rp 'Namespace: ' ORB_NAMESPACE
  read -rp 'Orb name: ' ORB_NAME
  read -rp 'Context name: ' ORB_CONTEXT_NAME
}

replace_values() {
  sed -i '' "s/<namespace>/$ORB_NAMESPACE/g" .circleci/config.yml
  sed -i '' "s/<orb-name>/$ORB_NAME/g" .circleci/config.yml
  sed -i '' "s/<publishing-context>/$ORB_CONTEXT_NAME/g" .circleci/config.yml

  sed -i '' "s/<namespace>/$ORB_NAMESPACE/g" .circleci/test-deploy.yml
  sed -i '' "s/<orb-name>/$ORB_NAME/g" .circleci/test-deploy.yml
  sed -i '' "s/<publishing-context>/$ORB_CONTEXT_NAME/g" .circleci/test-deploy.yml
}

msg_success() {
  echo "Successfully upgraded config files."
  echo "You must now open \"test-deploy.yml\" and add your integrations tests."
  echo "Docs: https://circleci.com/docs/2.0/testing-orbs/#integration-testing"
  echo
  echo "When complete, delete the '.bak' files in the .circleci directory."
  echo 'Commit your changes and the next version of your orb will be published when a tag is created.'
}

destroy_script() {
  rm -f "$0"
}

verify_run
user_input
backup_contents
download_template
replace_values
copy_custom_components
msg_success
destroy_script
