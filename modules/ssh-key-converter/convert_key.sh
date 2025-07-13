#!/bin/bash
#shellcheck disable=all
set -euo pipefail


conv_key_2() {
#!/bin/sh

set -euf

ssl_priv=$(cat ${1:+"$1"})

pub64=$(echo "$ssl_priv" | openssl pkey -pubout -outform der | dd bs=12 skip=1 iflag=fullblock,skip_bytes | base64)

test "$pub64" || { echo "Cannot get public key" >&2; exit 1; }

priv64=$(echo "$ssl_priv" | grep -v '^-' | base64 -d | dd bs=16 skip=1 status=none | base64)

echo '-----BEGIN OPENSSH PRIVATE KEY-----'

{
    printf openssh-key-v1'\000\000\000\000\004'none'\000\000\000\004'none'\000\000\000\000\000\000\000\001\000\000\000'3
    printf '\000\000\000\013'ssh-ed25519'\000\000\000 '
    echo $pub64 | base64 -d
    printf '\000\000\000'
    printf '\210\000\000\000\000\000\000\000\000'
    printf '\000\000\000\013'ssh-ed25519'\000\000\000 '
    echo $pub64 | base64 -d
    printf '\000\000\000@'
    echo $priv64| base64 -d
    echo $pub64 | base64 -d
    printf '\000\000\000\000\001\002\003\004\005'
} | base64

echo '-----END OPENSSH PRIVATE KEY-----'

    
}

# Extract the PKCS8 key directly from stdin
pkcs8_key="$(jq -r '.pkcs8_key')"

# Convert PKCS8 to PEM format using ssh-keygen with pipes
#if pem_key="$(echo "${pkcs8_key}" | ssh-keygen -i -f /dev/stdin -m pkcs8 )"; then
if pem_key="$(echo "${pkcs8_key}" | conv_key_2 )"; then
    # Output as JSON (required by external data source)
    jq -n --arg pem_key "${pem_key}" '{"pem_key": $pem_key}'
else
    echo "Error: Failed to convert PKCS8 key to PEM format" >&2
    exit 1
fi