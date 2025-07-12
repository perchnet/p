# modules/coreos-vm/outputs.tf
output "vm_id" {
  description = "proxmox vm id"
  value       = proxmox_virtual_environment_vm.coreos_vm.vm_id
}
# output "vm_mac0" {
#   description = "proxmox vm 0th mac"
#   value       = proxmox_virtual_environment_vm.coreos_vm.network_device[0].mac_address
# }
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
