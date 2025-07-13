#!/bin/bash
#shellcheck disable=all
set -euvo pipefail

conv_key_2() {
    local ssl_priv="$1"
    local pub64 priv64
    
    # Extract public key in base64 format
    pub64=$(printf '%s\n' "$ssl_priv" | openssl pkey -pubout -outform der | tail -c+13 | base64 -w0)
    
    if [[ -z "$pub64" ]]; then
        echo "Cannot get public key" >&2
        exit 1
    fi
    
    # Extract private key part - remove PEM headers, decode, and skip first 16 bytes
    local base64_data
    base64_data=$(printf '%s\n' "$ssl_priv" | sed '/^-/d' | tr -d '\n')
    
    # Decode base64 to hex, skip first 32 hex chars (16 bytes), then back to base64
    local hex_data
    hex_data=$(base64 -d <<< "$base64_data" | xxd -p -c0)
    priv64=$(printf '%s' "${hex_data:32}" | xxd -r -p | base64 -w0)
    
    printf '%s\n' '-----BEGIN OPENSSH PRIVATE KEY-----'
    
    # Build OpenSSH private key structure in one go
    {
        printf 'openssh-key-v1\000\000\000\000\004none\000\000\000\004none\000\000\000\000\000\000\000\001\000\000\000\063'
        printf '\000\000\000\013ssh-ed25519\000\000\000\040'
        base64 -d <<< "$pub64"
        printf '\000\000\000\210\000\000\000\000\000\000\000\000'
        printf '\000\000\000\013ssh-ed25519\000\000\000\040'
        base64 -d <<< "$pub64"
        printf '\000\000\000\100'
        base64 -d <<< "$priv64"
        base64 -d <<< "$pub64"
        printf '\000\000\000\000\001\002\003\004\005'
    } | base64 -w0
    
    printf '\n%s\n' '-----END OPENSSH PRIVATE KEY-----'
}

# Read and parse input JSON
read -r input_json
pkcs8_key=$(jq -r '.pkcs8_key' <<< "$input_json")

# Convert PKCS8 to OpenSSH format
if pem_key=$(conv_key_2 "$pkcs8_key"); then
    # Output result as JSON
    jq -n --arg pem_key "$pem_key" '{"pem_key": $pem_key}'
else
    echo "Error: Failed to convert PKCS8 key to PEM format" >&2
    exit 1
fi