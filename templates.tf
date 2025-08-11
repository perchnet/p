module "debian13" {
  source = "github.com/b-/terraform-bpg-proxmox//modules/vm-template?ref=fffd5e4"

  efi_disk_storage = "zssd"
  ci_datastore_id  = "zssd"
  #disks = [ {disk_storage = "zssd"} ]
  disk_storage = "zssd"


  node = local.pve_node

  # Image Variables
  image_filename           = "debian-13-generic-amd64.img" # Convert *.qcow2 image to *.img
  image_url                = "https://cloud.debian.org/images/cloud/trixie/20250806-2196/debian-13-generic-amd64-20250806-2196.qcow2"
  image_checksum           = "a7dfe434afc40afb0a791c777f3edba6b1a5c4b7315a61073fe5e34752d3bc5fd44ff67ef054eb4263687a97f7ce4896bf5bad5f216ef8b9d4a84541759e743d"
  image_checksum_algorithm = "sha512"
  image_overwrite          = false

  # VM Template Variables
  qemu_guest_agent = false
  vm_id            = 9013
  vm_name          = "debian13"
  #description      = "Terraform generated template on ${timestamp()}"
  tags = ["terraform", "template", "debian"]
  #ci_vendor_data = "local:snippets/vendor-data.yaml"
}
module "ubuntu22" {
  source = "github.com/b-/terraform-bpg-proxmox//modules/vm-template?ref=fffd5e4"

  disk_storage = "zssd"
  #scsihw = "virtio-scsi-single"
  efi_disk_storage = "zssd"
  ci_datastore_id  = "zssd"
  #disks = [ {disk_storage = "zssd"} ]

  node = local.pve_node # Required

  # Image Variables
  image_url                = "https://cloud-images.ubuntu.com/releases/22.04/release-20240207/ubuntu-22.04-server-cloudimg-amd64.img" # Required
  image_checksum           = "7eb9f1480956af75359130cd41ba24419d6fd88d3af990ea9abe97c2f9459fda"                                       # Required
  image_checksum_algorithm = "sha256"                                                                                                 # Optional
  image_overwrite          = false                                                                                                    # Optional

  # VM Template Variables
  qemu_guest_agent = false
  #vm_id       = 8022                                             # Required
  vm_name = "ubuntu22" # Optional
  #description = "Terraform generated template on ${timestamp()}" # Optional
  tags = ["terraform", "template", "ubuntu"] # Optional
  #ci_vendor_data = "local:snippets/vendor-data.yaml"                # Optional
}
