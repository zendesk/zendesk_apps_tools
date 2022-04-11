#!/usr/bin/env bash

if [[ -z "$(docker images -q zat:latest 2> /dev/null)" ]]; then
  echo "ZAT Image not found, building..."
  ./scripts/compile.sh
fi

./scripts/invoke.sh "$@"
