resource "proxmox_virtual_environment_vm" "block_storage" {
  node_name = var.node
  started   = false
  on_boot   = false

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
