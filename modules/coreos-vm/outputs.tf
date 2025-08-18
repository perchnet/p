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

output "ipv4_addresses" {
  description = "The IPv4 addresses per network interface published by the QEMU agent (empty list when agent.enabled is false)"
  value       = proxmox_virtual_environment_vm.coreos_vm.ipv4_addresses
}
output "ipv6_addresses" {
  description = "The IPv6 addresses per network interface published by the QEMU agent (empty list when agent.enabled is false)"
  value       = proxmox_virtual_environment_vm.coreos_vm.ipv6_addresses
}
output "mac_addresses" {
  description = "The MAC addresses published by the QEMU agent with fallback to the network device configuration, if the agent is disabled"
  value       = proxmox_virtual_environment_vm.coreos_vm.mac_addresses
}
output "network_interface_names" {
  description = "The network interface names published by the QEMU agent"
  value       = proxmox_virtual_environment_vm.coreos_vm.network_interface_names
}
