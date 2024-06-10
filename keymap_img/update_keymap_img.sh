#!/bin/sh

kb=$1

if [ -z $kb ]; then
  echo "Need to choose a keyboard"
  exit 1
fi

echo 'Parsing ZMK keymap...'
keymap -c config.yaml parse -c 10 -z "../config/${kb}.keymap" > "${kb}_keymap.yaml"

echo '\n\nDrawing keymap...'
keymap -c config.yaml draw -k "$kb" "${kb}_keymap.yaml" > "${kb}_keymap.svg"

open "${kb}_keymap.svg"
