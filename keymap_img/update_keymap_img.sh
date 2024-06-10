#!/bin/sh

kb=$1

if [ -z $kb ]; then
  echo "Need to choose a keyboard"
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

open "${kb}_keymap.svg"
