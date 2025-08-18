#!/bin/bash
set -euxo pipefail

DIR="$(mktemp -d)"
trap 'rm -rf ${DIR}' EXIT

# stupid large bin seems like one of the least stupid ways around this
curl -fsSL "https://github.com/b-/sshpk-sea/releases/download/sshpk-conv/sshpk-conv" > "${DIR}/sshpk-conv"
chmod +x "${DIR}/sshpk-conv"

# Extract the PKCS8 key directly from stdin
# Convert PKCS8 to PEM format using ssh-keygen with pipes
    # Output as JSON (required by external data source)
OUT="$(jq -r '.pkcs8_key' |
    "${DIR}"/sshpk-conv --informat=pkcs8 --outformat=openssh --private)"
    jq -n --arg pem_key "${OUT}" '{"pem_key": $pem_key}'
