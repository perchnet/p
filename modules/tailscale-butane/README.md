# Example usage of the tailscale-vm module

```hcl
module "my_tailscale_vm" {
  source = "./modules/tailscale-vm"

  # Tailscale configuration
  tailscale_hostname               = "my-coreos-vm"
  tailscale_tags                   = ["tag:server", "tag:homelab"]
  tailscale_auth_key_expiry_hours  = 2  # Key expires in 2 hours

  # VM configuration
  username                = "core"
  password                = "your-secure-password"
  pve_node                = "pve1"
  node_name               = "pve1"
  vm_description          = "CoreOS VM with Tailscale"
  vm_memory               = 4096
  vm_disk_size            = 40
  vm_authorized_keys      = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-public-key"
  ]
  
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
    vm_id                = module.my_tailscale_vm.vm_id
    vm_name              = module.my_tailscale_vm.vm_name
    tailscale_hostname   = module.my_tailscale_vm.tailscale_hostname
    auth_key_expiry      = module.my_tailscale_vm.tailscale_auth_key_expiry
  }
}

output "breakglass_credentials" {
  value = {
    user     = module.my_tailscale_vm.breakglass_user
    password = module.my_tailscale_vm.breakglass_password
  }
  sensitive = true
}
```
