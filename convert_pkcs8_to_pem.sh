#!/bin/bash
set -euo pipefail

input=$(cat)
pkcs8_key=$(echo "${input}" | jq -r '.pkcs8_key')

# Convert the key using stdin/stdout (no temp files)
pem_key=$(echo "${pkcs8_key}" \
  | ssh-keygen -m PEM -i -f /dev/stdin 2>/dev/null)

# Return as JSON
jq -n --arg pem "${pem_key}" '{"pem_key": $pem}'
