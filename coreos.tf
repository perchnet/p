module "coreos-module-vm" {
  source   = "./modules/coreos-vm"
  password = onepassword_item.coreos_module_password.password
  username = onepassword_item.coreos_module_password.username
  #vm_vga_type = "serial0"
  vm_authorized_keys    = [data.onepassword_item.proxmox_ssh.note_value]
  pve_disk_datastore_id = "zssd"
  pve_iso_datastore_id  = "zssd-files"
  vm_agent_enabled      = true
  node_name             = local.pve_node
  #vm_id                 = 1234567
  extra_butane_snippets = [
    templatefile("./modules/coreos-vm/ct/autorebase.yaml.tftpl", {
      target_image = "ghcr.io/perchnet/qcore:latest"
    }),
    file("./modules/coreos-vm/ct/setup-periphery.yaml")
  ]
}
module "coreos-module-vm2" {
  #vm_id                 = 2345678
  source                = "./modules/coreos-vm"
  password              = onepassword_item.coreos_module_password.password
  username              = onepassword_item.coreos_module_password.username
  vm_vga_type           = "serial0"
  vm_authorized_keys    = [data.onepassword_item.proxmox_ssh.note_value]
  pve_disk_datastore_id = "zssd"
  pve_iso_datastore_id  = "zssd-files"
  vm_agent_enabled      = true
  extra_butane_snippets = [
    templatefile("./modules/coreos-vm/ct/autorebase.yaml.tftpl", {
      target_image = "ghcr.io/perchnet/qcore:latest"
    }),
    file("./modules/coreos-vm/ct/setup-periphery.yaml")
  ]
  node_name = local.pve_node
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

# Example usage of the tailscale-vm module

module "my_tailscale_vm" {
  source = "./modules/tailscale-vm"

  # Tailscale configuration
  tailscale_hostname              = "my-coreos-vm"
  tailscale_tags                  = ["tag:server", "tag:homelab"]
  tailscale_auth_key_expiry_hours = 2 # Key expires in 2 hours

  # VM configuration
  password              = onepassword_item.coreos_module_password.password
  username              = onepassword_item.coreos_module_password.username
  vm_vga_type           = "serial0"
  vm_authorized_keys    = [data.onepassword_item.proxmox_ssh.note_value]
  pve_disk_datastore_id = "zssd"
  pve_iso_datastore_id  = "zssd-files"
  vm_agent_enabled      = true
  pve_node              = "pve1"
  node_name             = "pve1"
  vm_description        = "CoreOS VM with Tailscale"
  vm_memory             = 4096
  vm_disk_size          = 40

  # Optional: additional butane snippets
  extra_butane_snippets = [
    <<-EOF
    storage:
      files:
        - path: /etc/hostname
          mode: 0644
          contents:
            inline: my-coreos-vm
    EOF
  ]
}

# Outputs
output "vm_info" {
  value = {
    vm_id              = module.my_tailscale_vm.vm_id
    vm_name            = module.my_tailscale_vm.vm_name
    tailscale_hostname = module.my_tailscale_vm.tailscale_hostname
    auth_key_expiry    = module.my_tailscale_vm.tailscale_auth_key_expiry
  }
}

output "breakglass_credentials" {
  value = {
    user     = module.my_tailscale_vm.breakglass_user
    password = module.my_tailscale_vm.breakglass_password
  }
  sensitive = true
}
