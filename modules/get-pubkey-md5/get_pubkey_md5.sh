#!/usr/bin/env bash

set -euo pipefail

# Read JSON from stdin and extract the private key
input=$(jq -r '.private_key' < /dev/stdin)

# Exit if the key is empty or missing
if [[ -z "${input}" || "${input}" == "null" ]]; then
  echo '{"error": "Missing or empty private_key input"}'
  exit 1
fi

# Run the openssl pipeline to get the MD5 digest of the public key
md5_output=$(echo "${input}" | openssl pkey -outform DER -pubout 2>/dev/null | openssl dgst -md5 -c)

# Extract just the MD5 hash
md5_hash=$(echo "${md5_output}" | awk '{print $2}')

# Return the result in JSON format
jq -n --arg pubkey_md5 "${md5_hash}" '{"pubkey_md5": $pubkey_md5}'
