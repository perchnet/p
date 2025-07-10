# locals {
#   # cloud_init_datastore_id = "zssd-files"
#   metadata = jsondecode(data.http.coreos_stable_metadata.response_body)
# 
#   coreos_proxmoxve_stable = local.metadata.architectures.x86_64.artifacts.proxmoxve.formats["qcow2.xz"].disk
#   download_url            = local.coreos_proxmoxve_stable.location
#   download_sum            = local.coreos_proxmoxve_stable.sha256
#   coreos_username         = "core"
#   coreos_password         = resource.onepassword_item.coreos_password.password
# 
# }
# 
# resource "onepassword_item" "coreos_password" {
#   vault    = local.perchnet_vault
#   title    = "coreos-password"
#   username = local.coreos_username
#   password_recipe {
#     length  = 40
#     digits  = true
#     letters = true
#     symbols = true
#   }
# 
# }
# 
# 
# data "http" "coreos_stable_metadata" {
#   url = "https://builds.coreos.fedoraproject.org/streams/testing.json"
# }
# 
# resource "proxmox_virtual_environment_download_file" "coreos_img" {
#   content_type = "iso"
#   datastore_id = "local"
#   node_name    = var.node
# 
#   url                = local.download_url
#   checksum           = local.download_sum
#   checksum_algorithm = "sha256"
# 
#   file_name               = "coreos-proxmoxve.qcow2.xz.img"
#   decompression_algorithm = "zst"
# }
# resource "proxmox_virtual_environment_vm" "coreos-testing" {
#   # This must be the name of your Proxmox node within Proxmox
#   node_name   = var.node
#   name        = "coreos-testing"
#   description = "Managed by Terraform"
# 
#   started = true
# 
#   machine = "q35"
# 
#   # Since we're installing the guest agent in our Butane config,
#   # we should enable it here for better integration with Proxmox
#   agent {
#     enabled = false #true
#   }
# 
#   vga {
#     type = "serial0"
#   }
# 
#   serial_device {
#     device = "socket"
#   }
# 
#   memory {
#     dedicated = 2048
#   }
# 
#   # Here we're referencing the file we uploaded before. Proxmox will
#   # clone a new disk from it with the size we're defining.
#   disk {
#     interface    = "virtio0"
#     datastore_id = "zssd" # TODO: move to vars
#     file_id      = proxmox_virtual_environment_download_file.coreos_img.id
#     size         = 32
#   }
# 
#   # We need a network connection so that we can install the guest agent
#   network_device {
#     bridge = "vmbr0"
#   }
# 
#   initialization {
#     interface         = "ide2"
#     datastore_id      = local.cloud_init_datastore_id
#     user_data_file_id = proxmox_virtual_environment_file.cloud_user_config.id
#   }
# }
# 
# # Butane Config for Fedora CoreOS
# data "ct_config" "fedora-coreos-config" {
#   content = templatefile("${path.module}/ct/fcos.yaml", {
#     message = "Hello World!", sshkey = data.onepassword_item.proxmox_ssh.note_value, password = local.coreos_password, username = local.coreos_username
#   })
#   strict       = true
#   pretty_print = true
# 
#   snippets = [
#     file("${path.module}/ct/fcos-snippet.yaml"),
#   ]
# }
# 
# # Render as Ignition
# resource "proxmox_virtual_environment_file" "cloud_user_config" {
#   content_type = "snippets"
#   datastore_id = local.cloud_init_datastore_id
#   node_name    = var.node
# 
#   source_raw {
#     data      = data.ct_config.fedora-coreos-config.rendered
#     file_name = "test.butane-ci-user-data.ign"
#   }
# }
# 
# #resource "local_file" "fedora-coreos" {
# #  content  = data.ct_config.fedora-coreos-config.rendered
# #  filename = "${path.module}/output/fedora-coreos.ign"
# #}
# 
# # # This is my personal VM module I use in my lab. It does not apply any specific customizations, so I am omitting the full contents of the module.
# # module "coreos-testing" {
# #   source = "./modules/vm"
# # 
# #   id       = xxx
# #   name = "coreos-tf"
# # 
# #   disk = {
# #     size    = 16 # The qcow2 image is 10Gb when pulled as of writing, but is successfully sized up during provisioning
# #     file_id = proxmox_virtual_environment_download_file.coreos_img.id
# #   }
# # 
# #   # I found that having less memory would cause boot failures without explicit mention as to why.
# #   # It took a while to figure out that this was because of the lack of memory and not because the disk extraction was going wrong.
# #   memory = 2
# # 
# #   agent_enabled = false
# # 
# #   cloud_init = {
# #     enabled = false
# #   }
# # }
# 
# # data "ct_config" "gitea_runner_ignition" {
# #   strict = true
# #   content = templatefile("butane/gitea-runner-vm.yaml.tftpl", {
# #     ssh_admin_username              = "username"
# #     ssh_admin_public_key            = file("../ssh_pub_keys/username.pub")
# #     hostname                        = "gitea_runner"
# #     gitea_runner_registration_token = data.onepassword_item.gitea_runner_registration_token.credential
# #     gitea_deploy_user               = data.onepassword_item.gitea_actions_deploy_credentials.username
# #     gitea_deploy_pass               = data.onepassword_item.gitea_actions_deploy_credentials.credential
# #   })
# # }
# # 
# # resource "proxmox_virtual_environment_file" "cloud_user_config" {
# #   content_type = "snippets"
# #   datastore_id = "my-storage"
# #   node_name    = "my-node"
# # 
# #   source_raw {
# #     data = data.ct_config.gitea_runner_ignition.rendered
# # 
# #     file_name = "gitea_runner.butane-ci-user-data.yml"
# #   }
# # }
# # 
# # resource "proxmox_virtual_environment_vm" "gitea_runner_vm" {
# #   # This must be the name of your Proxmox node within Proxmox
# #   node_name   = "my-node"
# #   name        = "gitea-runner"
# #   description = "Managed by Terraform"
# # 
# #   started = true
# # 
# #   machine = "q35"
# # 
# #   # Since we're installing the guest agent in our Butane config,
# #   # we should enable it here for better integration with Proxmox
# #   agent {
# #     enabled = true
# #   }
# # 
# #   vga {
# #     type = "serial0"
# #   }
# # 
# #   serial_device {
# #     device = "socket"
# #   }
# # 
# #   memory {
# #     dedicated = 2048
# #   }
# # 
# #   # Here we're referencing the file we uploaded before. Proxmox will
# #   # clone a new disk from it with the size we're defining.
# #   disk {
# #     interface    = "virtio0"
# #     datastore_id = "my-storage"
# #     file_id      = proxmox_virtual_environment_file.coreos_qcow2.id
# #     size         = 32
# #   }
# # 
# #   # We need a network connection so that we can install the guest agent
# #   network_device {
# #     bridge = "vmbr0"
# #   }
# # 
# #   initialization {
# #     interface         = "ide2"
# #     datastore_id      = "my-storage"
# #     user_data_file_id = proxmox_virtual_environment_file.cloud_user_config.id
# #   }
# # }
# # 
# 