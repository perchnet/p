output "disk" {
  description = "The disk object."
  value       = proxmox_virtual_environment_vm.block_storage.disk[0]
}
output "storage" {
  value = proxmox_virtual_environment_vm.block_storage.disk[0].datastore_id
}
output "file_format" {
  value = proxmox_virtual_environment_vm.block_storage.disk[0].file_format
}
output "size" {
  value = proxmox_virtual_environment_vm.block_storage.disk[0].size
}
output "id" {
  value = proxmox_virtual_environment_vm.block_storage.disk[0].path_in_datastore
}
