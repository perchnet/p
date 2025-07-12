#!/bin/bash
set -euo pipefail

input=$(cat)
node=$(echo "${input}" | jq -r '.node')
vmid=$(echo "${input}" | jq -r '.vmid')
host=$(echo "${input}" | jq -r '.host')
user=$(echo "${input}" | jq -r '.user')
ssh_key=$(echo "${input}" | jq -r '.ssh_key // empty')
password=$(echo "${input}" | jq -r '.password // empty')

if [[ -n "${ssh_key}" ]]; then
  keyfile="$(mktemp)"
  chmod 600 "${keyfile}"
  echo "${ssh_key}" > "${keyfile}"

  uuid=$(ssh -i "${keyfile}" -o StrictHostKeyChecking=no "${user}@${host}" \
    "pvesh get /nodes/$node/qemu/${vmid}/config" \
    | grep smbios1 \
    | sed -n 's/.*uuid=\([^,]*\).*/\1/p')

  rm -f "$keyfile"

elif [ -n "$password" ]; then
  if ! command -v sshpass &> /dev/null; then
    echo '{"error":"sshpass is required for password authentication"}'
    exit 1
  fi

  uuid=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user@$host" \
    "pvesh get /nodes/$node/qemu/$vmid/config" \
    | grep smbios1 \
    | sed -n 's/.*uuid=\([^,]*\).*/\1/p')

else
  echo '{"error":"No SSH key or password provided"}'
  exit 1
fi

jq -n --arg uuid "$uuid" '{uuid: $uuid}'
