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
  echo "No keyboard specified, using forager as default"
  kb="forager"
fi

if [ -f "${kb}_keymap.yaml" ]; then
  rm "${kb}_keymap.yaml"
fi

if [ -f "${kb}_keymap.svg" ]; then
  rm "${kb}_keymap.svg"
fi

keymap -c my_config.yaml parse -z "../config/${kb}.keymap" -o "${kb}_keymap.yaml"
keymap -c my_config.yaml draw -j "../config/${kb}.json" "${kb}_keymap.yaml" > "${kb}_keymap.svg"

if [ "$ci_mode" = false ]; then
  if command -v open >/dev/null; then open "${kb}_keymap.svg"; else xdg-open "${kb}_keymap.svg"; fi
fi
