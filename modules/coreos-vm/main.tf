terraform {
  required_version = ">= 1.0"
  required_providers {
    ct = { # CoreOS Transpiler
      source  = "poseidon/ct"
      version = "0.13.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.79"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 3.5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = ">= 1.2.1"
    }

  }
}

module "coreos_metadata" {
  source = "github.com/perchnet/terraform-module-coreos-metadata?ref=c700d78"

  platform = "proxmoxve"
  stream   = var.coreos_stream
}

locals {
  coreos_username = var.username
  coreos_password = var.password


  vm_name     = random_pet.random_hostname.id
  vm_hostname = local.vm_name


}
resource "random_pet" "random_hostname" {}
resource "proxmox_virtual_environment_download_file" "coreos_img" {
  content_type = "iso"
  datastore_id = var.pve_iso_datastore_id
  node_name    = var.pve_node

  url                = module.coreos_metadata.download_url
  checksum           = module.coreos_metadata.download_sum
  checksum_algorithm = "sha256"

  # proxmox won't download it unless you say it ends in .img
  file_name               = "${module.coreos_metadata.coreos_img_filename}.img"
  decompression_algorithm = "zst"
}
resource "proxmox_virtual_environment_vm" "coreos_vm" {
  # This must be the name of your Proxmox node within Proxmox
  node_name   = var.node_name
  name        = local.vm_name
  description = var.vm_description

  tags = concat(var.vm_tags, [var.vm_managed_tag])

  started = true

  vm_id   = var.vm_id
  machine = "q35"

  # Since we're installing the guest agent in our Butane config,
  # we should enable it here for better integration with Proxmox
  agent {
    enabled = var.vm_agent_enabled
  }
  stop_on_destroy = true # in case agent doesn't work out

  vga {
    type = var.vm_vga_type
  }

  serial_device {
    device = "socket"
  }

  memory {
    dedicated = var.vm_memory
  }

  operating_system {
    type = "l26"
  }

  # Here we're referencing the file we uploaded before. Proxmox will
  # clone a new disk from it with the size we're defining.
  disk {
    interface    = "scsi0"
    datastore_id = var.pve_disk_datastore_id
    file_id      = proxmox_virtual_environment_download_file.coreos_img.id
    size         = var.vm_disk_size
  }

  # We need a network connection so that we can install the guest agent
  network_device {
    bridge = var.vm_network_bridge
  }

  initialization {
    interface         = "ide2"
    datastore_id      = var.vm_cloud_init_datastore_id
    user_data_file_id = proxmox_virtual_environment_file.cloud_user_config.id
  }
}
