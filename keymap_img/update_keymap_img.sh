#!/bin/sh

kb=$1
ci_mode=false

# Parse arguments
while [ $# -gt 0 ]; do
  case $1 in
    --ci)
      ci_mode=true
      shift
      ;;
    *)
      kb=$1
      shift
      ;;
  esac
done

if [ -z $kb ]; then
  echo "Need to choose a keyboard"
  echo "Usage: $0 [--ci] <keyboard>"
  exit 1
fi

if [ -f "${kb}_keymap.yaml" ]; then
  rm "${kb}_keymap.yaml"
fi

if [ -f "${kb}_keymap.svg" ]; then
  rm "${kb}_keymap.svg"
fi

keymap -c my_config.yaml parse -c 10 -z "../config/${kb}.keymap" > "${kb}_keymap.yaml"
keymap -c my_config.yaml draw -k "$kb" "${kb}_keymap.yaml" > "${kb}_keymap.svg"

if [ "$ci_mode" = false ]; then
  open "${kb}_keymap.svg"
fi
