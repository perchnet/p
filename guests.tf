#module "ubuntu_dev_vm" {
#  source            = "./modules/ubuntu-vm"
#  import_from_image = module.proxmox_images.images["ubuntu_jammy"].id
#}
locals {
  ubuntu_vm_name = "vm-ubuntu22-minimal"                          # optional
  ci_ssh_keys    = [data.onepassword_item.proxmox_ssh.public_key] # optional, add SSH key to "default" user
}
module "vm_minimal_config" {
  source = "github.com/b-/terraform-bpg-proxmox//modules/vm?ref=a38e3ce"
  #source = "/home/bri/dev/terraform-proxmox-modules/modules/vm"

  #full_clone = false
  scsihw = "virtio-scsi-single"
  #efi_disk_storage = "zssd"
  cloudinit = {
    datastore_id     = "zssd-files"
    snippets_storage = "snippets"
    user_data        = <<-EOF
      #cloud-config
      hostname: ${local.ubuntu_vm_name}
      ssh_authorized_keys: ${jsonencode(local.ci_ssh_keys)}
      timezone: America/New_York
      packages:
            - qemu-guest-agent
      runcmd:
        - ['sh', '-c', 'curl -fsSL https://tailscale.com/install.sh | sh']
        - tailscale up --authkey ${tailscale_tailnet_key.tailscale_key.key} --accept-routes --accept-dns
    EOF
  }
  #disks            = [{ disk_storage = "zssd" }]
  qemu_guest_agent = false

  node = local.pve_node
  #vm_id                 = 10000 # required
  name = local.ubuntu_vm_name
  clone = {
    template_node = local.pve_node
    template_id   = module.ubuntu22.id
    #full          = false
  }
  depends_on = [module.ubuntu22]
  #ci_ssh_keys             = [data.onepassword_item.proxmox_ssh.public_key] # optional, add SSH key to "default" user
}

resource "tailscale_tailnet_key" "tailscale_key" {
  reusable      = true
  ephemeral     = false               # Keep node when offline
  preauthorized = true                # Auto-authorize
  expiry        = 600                 #local.rotation_seconds
  tags          = ["tag:web-ingress"] #local.tailscale_tags
  #  lifecycle {
  #    replace_triggered_by = [time_rotating.rotate_tailnet_key]
  #  }
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
