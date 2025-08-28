locals {
  name        = var.name
  description = var.description != null ? var.description : "Terraform block storage created on ${time_static.creation_date.rfc3339}"
}
resource "time_static" "creation_date" {
}
resource "terraform_data" "name" {

}
resource "proxmox_virtual_environment_vm" "block_storage" {
  node_name   = var.node
  started     = false
  on_boot     = false
  name        = local.name
  description = local.description
  tags        = var.tags

  boot_order = ["ide3"] # set to empty cdrom
  cdrom {               # to force the VM to be unbootable
    file_id   = "none"  # leave drive empty
    interface = "ide3"
  }
  disk {
    datastore_id = var.storage
    interface    = "scsi0"
    size         = var.size
  }
}
