#module "ubuntu_dev_vm" {
#  source            = "./modules/ubuntu-vm"
#  import_from_image = module.proxmox_images.images["ubuntu_jammy"].id
#}
module "ubuntu22" {
  source = "github.com/trfore/terraform-bpg-proxmox//modules/vm-template?ref=8ae945c"

  node = local.pve_node # Required

  # Image Variables
  image_url                = "https://cloud-images.ubuntu.com/releases/22.04/release-20240207/ubuntu-22.04-server-cloudimg-amd64.img" # Required
  image_checksum           = "7eb9f1480956af75359130cd41ba24419d6fd88d3af990ea9abe97c2f9459fda"                                       # Required
  image_checksum_algorithm = "sha256"                                                                                                 # Optional
  image_overwrite          = false                                                                                                    # Optional

  # VM Template Variables
  vm_id       = 8022                                             # Required
  vm_name     = "ubuntu22"                                       # Optional
  description = "Terraform generated template on ${timestamp()}" # Optional
  tags        = ["terraform", "template", "ubuntu"]              # Optional
  #ci_vendor_data = "local:snippets/vendor-data.yaml"                # Optional
}
module "vm_minimal_config" {
  source = "github.com/trfore/terraform-bpg-proxmox//modules/vm-clone?ref=8ae945c"

  node        = "pve"                   # required
  vm_id       = 100                     # required
  vm_name     = "vm-example-minimal"    # optional
  template_id = 8022                    # required
  ci_ssh_key  = "~/.ssh/id_ed25519.pub" # optional, add SSH key to "default" user
}

module "debian12" {
  source = "github.com/trfore/terraform-bpg-proxmox//modules/vm-template?ref=8ae945c"

  node = local.pve_node

  # Image Variables
  image_filename           = "debian-12-generic-amd64.img" # Convert *.qcow2 image to *.img
  image_url                = "https://cloud.debian.org/images/cloud/trixie/20250806-2196/debian-13-generic-amd64-20250806-2196.qcow2"
  image_checksum           = "a7dfe434afc40afb0a791c777f3edba6b1a5c4b7315a61073fe5e34752d3bc5fd44ff67ef054eb4263687a97f7ce4896bf5bad5f216ef8b9d4a84541759e743d"
  image_checksum_algorithm = "sha512"
  image_overwrite          = false

  # VM Template Variables
  vm_id       = 9012
  vm_name     = "debian12"
  description = "Terraform generated template on ${timestamp()}"
  tags        = ["terraform", "template", "debian"]
  #ci_vendor_data = "local:snippets/vendor-data.yaml"
}
# locals {
#   cloud_init_datastore_id = "zssd-files"
# }
# resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
#   name      = "test-ubuntu"
#   node_name = var.node
#
#   # should be true if qemu agent is not installed / enabled on the VM
#   stop_on_destroy = true
#
#   initialization {
#     datastore_id = local.cloud_init_datastore_id
#     user_account {
#       # do not use this in production, configure your own ssh key instead!
#       username = "user"
#       password = "password"
#     }
#   }
#
#   disk {
#     datastore_id = "zssd"
#     file_id      = proxmox_virtual_environment_download_file.ubuntu_jammy_cloud_image.id
#     interface    = "virtio0"
#     iothread     = true
#     discard      = "on"
#     size         = 20
#   }
# }
#
# resource "proxmox_virtual_environment_vm" "ubuntu_vm_2" {
#   name        = "terraform-provider-proxmox-ubuntu-vm"
#   description = "Managed by Terraform"
#   tags        = ["terraform", "ubuntu"]
#
#   node_name = var.node
#   vm_id     = 4321
#
#   agent {
#     # read 'Qemu guest agent' section, change to true only when ready
#     enabled = false
#   }
#   # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
#   stop_on_destroy = true
#
# #   startup {
# #     order      = "3"
# #     up_delay   = "60"
# #     down_delay = "60"
# #   }
#
#   cpu {
#     cores        = 2
#     type         = "x86-64-v2-AES"  # recommended for modern CPUs
#   }
#
#   memory {
#     dedicated = 2048
#     floating  = 2048 # set equal to dedicated to enable ballooning
#   }
#
#   disk {
#     datastore_id = "zssd"
#     file_format = "raw"
#     import_from  = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_qcow2_img.id
#     interface    = "scsi0"
#   }
#
#   initialization {
#     datastore_id = local.cloud_init_datastore_id
#     ip_config {
#       ipv4 {
#         address = "dhcp"
#       }
#     }
#
#     user_account {
#       keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
#       password = random_password.ubuntu_vm_password.result
#       username = "ubuntu"
#     }
#
#     user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
#   }
#
#   network_device {
#     bridge = "vmbr0"
#   }
#
#   operating_system {
#     type = "l26"
#   }
#
#   tpm_state {
#     datastore_id = local.cloud_init_datastore_id
#     version = "v2.0"
#   }
#
#   serial_device {}
#
#   virtiofs {
#     mapping = "rust-root"
#     cache = "always"
#     direct_io = true
#   }
# }
#
# resource "proxmox_virtual_environment_file" "cloud_config" {
#   content_type = "snippets"
#   datastore_id = "snippets"
#   node_name    = var.node
#
#   source_raw {
#     data = <<-EOF
#     #cloud-config
#     chpasswd:
#       list: |
#         ubuntu:example
#       expire: false
#     hostname: example-hostname
#     packages:
#       - qemu-guest-agent
#     users:
#       - default
#       - name: ubuntu
#         groups: sudo
#         shell: /bin/bash
#         ssh-authorized-keys:
#           - ${trimspace(data.onepassword_item.proxmox_ssh.note_value)}
#         sudo: ALL=(ALL) NOPASSWD:ALL
#     EOF
#
#     file_name = "example.cloud-config.yaml"
#   }
# }
#
# resource "proxmox_virtual_environment_download_file" "latest_ubuntu_22_jammy_qcow2_img" {
#   content_type = "import"
#   datastore_id = "zssd-files"
#   node_name    = var.node
#   url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
#   # need to rename the file to *.qcow2 to indicate the actual file format for import
#   file_name = "jammy-server-cloudimg-amd64.qcow2"
# }
#
# resource "random_password" "ubuntu_vm_password" {
#   length           = 16
#   override_special = "_%@"
#   special          = true
# }
#
# resource "tls_private_key" "ubuntu_vm_key" {
#   algorithm = "ED25519"
#   #rsa_bits  = 2048
# }
#
# output "ubuntu_vm_password" {
#   value     = random_password.ubuntu_vm_password.result
#   sensitive = true
# }
#
# output "ubuntu_vm_private_key" {
#   value     = tls_private_key.ubuntu_vm_key.private_key_pem
#   sensitive = true
# }
#
# output "ubuntu_vm_public_key" {
#   value = tls_private_key.ubuntu_vm_key.public_key_openssh
# }
#
