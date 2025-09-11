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
  echo "No keyboard specified, using chocofi as default"
  kb="chocofi"
fi

if [ -f "${kb}_keymap.yaml" ]; then
  rm "${kb}_keymap.yaml"
fi

if [ -f "${kb}_keymap.svg" ]; then
  rm "${kb}_keymap.svg"
fi

keymap -c my_config.yaml parse -z "../config/${kb}.keymap" -o "${kb}_keymap.yaml"
keymap -c my_config.yaml draw "${kb}_keymap.yaml" > "${kb}_keymap.svg"

if [ "$ci_mode" = false ]; then
  open "${kb}_keymap.svg"
fi
