resource "random_id" "tailscale_host_suffix" {
  byte_length = 2
}
locals {
  user_hostname         = "tf-coreos-periphery"
  tailscale_host_suffix = random_id.tailscale_host_suffix.id
  hostname              = "${local.user_hostname}-${local.tailscale_host_suffix}"
  tailscale_tags        = ["tag:periphery"]
  coreos_img            = module.proxmox_images.images["coreos_img"]
  password              = onepassword_item.coreos_module_password.password
  username              = onepassword_item.coreos_module_password.username
  vm_vga_type           = "std"
  vm_authorized_keys    = [data.onepassword_item.proxmox_ssh.public_key]
  pve_disk_datastore_id = "zssd"
  pve_iso_datastore_id  = "zssd-files"
  vm_agent_enabled      = true
  #node_name             = local.pve_node
  vm_name = local.hostname
  #vm_id                 = 1234567
  extra_butane_snippets = [
    templatefile("./modules/coreos-vm/ct/autorebase.yaml.tftpl", {
      target_image = "ghcr.io/perchnet/qcore:latest"
    }),
  ]
}
resource "onepassword_item" "coreos_module_password" {
  vault    = local.perchnet_vault
  title    = "coreos-module-password"
  username = "core"
  password_recipe {
    length  = 40
    digits  = true
    letters = true
    symbols = false
  }
}

module "tailscale_butane" {
  source                   = "./modules/tailscale-butane"
  tailscale_auth_key       = tailscale_tailnet_key.key.key
  tailscale_tags           = local.tailscale_tags
  replace_when_key_changes = false
}
locals {
  rotation_seconds = 3600
}
resource "time_rotating" "rotate_tailnet_key" {
  rotation_minutes = (local.rotation_seconds / 60)
}
resource "tailscale_tailnet_key" "key" {
  reusable      = true
  ephemeral     = false # Keep node when offline
  preauthorized = true  # Auto-authorize
  expiry        = local.rotation_seconds
  tags          = ["tag:periphery"]
  lifecycle {
    replace_triggered_by = [
      time_rotating.rotate_tailnet_key,
      null_resource.tailscale_node_deletion_hook,
      #null_resource.vm_replacement_trigger,
    ]
  }
}
module "coreos-periphery-vm" {
  source                = "./modules/coreos-vm"
  coreos_img            = local.coreos_img
  password              = local.password
  username              = local.username
  vm_vga_type           = local.vm_vga_type
  vm_authorized_keys    = local.vm_authorized_keys
  pve_disk_datastore_id = local.pve_disk_datastore_id
  pve_iso_datastore_id  = local.pve_iso_datastore_id
  vm_agent_enabled      = local.vm_agent_enabled
  node_name             = local.node_name
  vm_name               = local.vm_name
  #vm_id                 = 1234567
  extra_butane_snippets = concat(local.extra_butane_snippets, [module.tailscale_butane.butane_snippet])
}
# data "http" "tailscale_node_deletion_token" {
#   url = "https://api.tailscale.com/api/v2/oauth/token"
# 
#   method = "POST"
# 
#   request_headers = {
#     Content-Type = "application/x-www-form-urlencoded"
#   }
# 
#   request_body = join("&", [
#     "client_id=${local.ts_oauth_id}",
#     "client_secret=${local.ts_oauth_secret}"
#   ])
# }
locals {
  tailscale_node_id = data.tailscale_device.tailscale_device.node_id

  #ts_oauth_token = jsondecode(data.http.tailscale_node_deletion_token.response_body).access_token
}

# NOTE: We _cannot_ use terrform_data here, unless and until
# Hashicorp decides to add a `sensitive = true` attribute to
# it, or otherwise decides to respect the sensitivity of its
# inputs when it generates its outputs.
#
resource "null_resource" "tailscale_node_deletion_hook" {
  triggers = {
    triggers_replace = data.tailscale_device.tailscale_device.node_id
    ts_oauth_id      = local.ts_oauth_id
    ts_oauth_secret  = local.ts_oauth_secret
    # ts_oauth_token = local.ts_oauth_token
    node_id = local.tailscale_node_id
  }
  lifecycle {
    ignore_changes = [
      triggers["ts_oauth_id"],
      triggers["ts_oauth_secret"],
      # triggers["node_id"]
    ]
  }
  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    environment = {
      OAUTH_CLIENT_ID     = self.triggers.ts_oauth_id
      OAUTH_CLIENT_SECRET = nonsensitive(self.triggers.ts_oauth_secret)
      #ts_oauth_token = self.triggers.ts_oauth_token
      node_id = self.triggers.node_id
    }
    command = <<-EOF
      #!/usr/bin/env bash
      token="$(curl -d "client_id=$${OAUTH_CLIENT_ID}" -d "client_secret=$${OAUTH_CLIENT_SECRET}" "https://api.tailscale.com/api/v2/oauth/token" | jq -r '.access_token')"
      response_code=$(curl -s -o /dev/null -w "%%{http_code}" "https://api.tailscale.com/api/v2/device/$${node_id}" \
        --request DELETE \
        --header 'Authorization: Bearer $${token}')

      case "$${response_code}" in
        200)
          echo "Success: Device deleted successfully."
          ;;
        400)
          echo "Error: Invalid device value."
          ;;
        403)
          echo "Error: Invalid API token."
          ;;
        500)
          echo "Error: Internal server error."
          ;;
        501)
          echo "Error: Device not owned by tailnet."
          ;;
        *)
          echo "Unexpected HTTP response: $response_code"
          ;;
      esac

    EOF
  }
}
data "tailscale_device" "tailscale_device" {
  hostname = local.hostname
  wait_for = "420s"
}
output "tailscale_node_id" {
  value = local.tailscale_node_id
}
