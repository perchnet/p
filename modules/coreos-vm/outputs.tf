# modules/coreos-vm/outputs.tf
output "vm_id" {
  description = "proxmox vm id"
  value       = proxmox_virtual_environment_vm.coreos_vm.vm_id
}
output "ignition_hash_short" {
  description = "ignition hash"
  value       = local.ignition_hash_short
  sensitive   = false
}
output "ignition_hash" {
  description = "ignition hash"
  value       = local.ignition_hash
  sensitive   = false
}
output "vm_name" {
  description = "vm name"
  value       = proxmox_virtual_environment_vm.coreos_vm.name
}
output "breakglass_user" {
  description = "breakglass user"
  value       = local.coreos_username
}
output "breakglass_password" {
  description = "breakglass password"
  value       = local.coreos_password
  sensitive   = true
}
