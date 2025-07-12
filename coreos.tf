module "coreos-module-vm" {
  source   = "./modules/coreos-vm"
  password = onepassword_item.coreos_module_password.password
  username = onepassword_item.coreos_module_password.username
  #vm_vga_type = "serial0"
  vm_authorized_keys    = [data.onepassword_item.proxmox_ssh.note_value]
  pve_disk_datastore_id = "zssd"
  pve_iso_datastore_id  = "zssd-files"
  vm_agent_enabled      = false
  node_name             = local.pve_node
  proxmox_host          = local.pve_host
}
module "coreos-module-vm2" {
  source                = "./modules/coreos-vm"
  password              = onepassword_item.coreos_module_password.password
  username              = onepassword_item.coreos_module_password.username
  vm_vga_type           = "serial0"
  vm_authorized_keys    = [data.onepassword_item.proxmox_ssh.note_value]
  pve_disk_datastore_id = "zssd"
  pve_iso_datastore_id  = "zssd-files"
  vm_agent_enabled      = false
  extra_butane_snippets = [
    templatefile("./modules/coreos-vm/ct/autorebase.yaml.tftpl", {
      target_image = "ghcr.io/ublue-os/ucore-hci:stable"
    }),
    file("./modules/coreos-vm/ct/setup-periphery.yaml")
  ]
  node_name    = local.pve_node
  proxmox_host = local.pve_host
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