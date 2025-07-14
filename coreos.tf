module "coreos-periphery-vm" {
  source                = "./modules/coreos-vm"
  coreos_img            = module.proxmox_images.images["coreos_img"]
  password              = onepassword_item.coreos_module_password.password
  username              = onepassword_item.coreos_module_password.username
  vm_vga_type           = "std"
  vm_authorized_keys    = [data.onepassword_item.proxmox_ssh.public_key]
  pve_disk_datastore_id = "zssd"
  pve_iso_datastore_id  = "zssd-files"
  vm_agent_enabled      = true
  node_name             = local.pve_node
  vm_name               = "coreos-periphery-test"
  #vm_id                 = 1234567
  extra_butane_snippets = [
    templatefile("./modules/coreos-vm/ct/autorebase.yaml.tftpl", {
      target_image = "ghcr.io/perchnet/qcore:latest"
    }),
    module.tailscale_butane.butane_snippet,
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
  tailscale_tags           = ["tag:periphery"]
  replace_when_key_changes = false
}
locals {
  rotation_seconds = 3600
  rotation_minutes = (local.rotation_seconds / 60)
}
resource "time_rotating" "rotate_tailnet_key" {
  rotation_minutes = local.rotation_minutes
}
resource "tailscale_tailnet_key" "key" {
  reusable      = false # Single-use key
  ephemeral     = false # Keep node when offline
  preauthorized = true  # Auto-authorize
  expiry        = local.rotation_seconds
  tags          = ["tag:periphery"]
  lifecycle {
    replace_triggered_by = [time_rotating.rotate_tailnet_key]
  }
}
