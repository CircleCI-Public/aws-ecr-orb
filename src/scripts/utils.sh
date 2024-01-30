#!/bin/bash

detect_os() { 
  detected_platform="$(uname -s | tr '[:upper:]' '[:lower:]')"

  case "$detected_platform" in
    linux*)
        if grep "Alpine" /etc/issue >/dev/null 2>&1; then
            printf '%s\n' "Detected OS: Alpine Linux."
            SYS_ENV_PLATFORM=linux_alpine
        else
            printf '%s\n' "Detected OS: Linux."
            SYS_ENV_PLATFORM=linux
        fi  
      ;;
    darwin*)
      printf '%s\n' "Detected OS: macOS."
      SYS_ENV_PLATFORM=macos
      ;;
    msys*|cygwin*)
      printf '%s\n' "Detected OS: Windows."
      SYS_ENV_PLATFORM=windows
      ;;
    *)
      printf '%s\n' "Unsupported OS: \"$detected_platform\"."
      exit 1
      ;;
  esac

  export SYS_ENV_PLATFORM
}

set_sudo(){
    if [ "$SYS_ENV_PLATFORM" = "linux_alpine" ]; then
        if [ "$ID" = 0 ]; then export SUDO=""; else export SUDO="sudo"; fi
    else
        if [ "$EUID" = 0 ]; then export SUDO=""; else export SUDO="sudo"; fi
    fi
}