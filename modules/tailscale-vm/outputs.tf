# modules/tailscale-vm/outputs.tf

# VM outputs
output "vm_id" {
  description = "Proxmox VM ID"
  value       = module.coreos_vm.vm_id
}

output "vm_name" {
  description = "VM name"
  value       = module.coreos_vm.vm_name
}

output "breakglass_user" {
  description = "Breakglass user"
  value       = module.coreos_vm.breakglass_user
}

output "breakglass_password" {
  description = "Breakglass password"
  value       = module.coreos_vm.breakglass_password
  sensitive   = true
}

# Tailscale outputs
output "tailscale_hostname" {
  description = "The hostname configured for Tailscale"
  value       = var.tailscale_hostname
}

output "tailscale_auth_key_id" {
  description = "The ID of the Tailscale auth key"
  value       = module.tailscale_auth_key.key_id
}

output "tailscale_auth_key_description" {
  description = "The description of the Tailscale auth key"
  value       = module.tailscale_auth_key.description
}

output "tailscale_auth_key_expiry" {
  description = "The expiry time of the Tailscale auth key"
  value       = module.tailscale_auth_key.expiry
}

output "tailscale_auth_key_capabilities" {
  description = "The capabilities of the Tailscale auth key"
  value       = module.tailscale_auth_key.capabilities
}

output "tailscale_tags" {
  description = "The tags applied to the Tailscale node"
  value       = module.tailscale_auth_key.tags
}
