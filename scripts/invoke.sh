#!/usr/bin/env bash

PROGNAME="$(basename $0)"
VERSION="0.0.1"

# Helper functions for guards
error(){
  error_code="$1"
  echo "ERROR: $2" >&2
  echo "($PROGNAME wrapper version: $VERSION, error code: $error_code )" &>2
  exit "$1"
}
check_cmd_in_path(){
  command -v "$1" >/dev/null 2>&1 || error 1 "Command '$1' not found in PATH"
}

# Guards (checks for dependencies)
check_cmd_in_path docker

# When running the zat container, mount the current directory to /app
# so that zat has access to it.
docker run \
    --network="bridge" \
    --interactive --tty --rm \
    --volume "$PWD":/wd \
    --workdir /wd \
    -p 4567:4567 \
    zat "$@"
