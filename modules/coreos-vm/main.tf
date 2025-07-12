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
locals {
  flat_hash = sha256(jsonencode({
    username                   = var.username
    password                   = var.password
    pve_node                   = var.pve_node
    vm_description             = var.vm_description
    vm_vga_type                = var.vm_vga_type
    vm_authorized_keys         = var.vm_authorized_keys
    vm_cloud_init_datastore_id = var.vm_cloud_init_datastore_id
    vm_snippets_datastore_id   = var.vm_snippets_datastore_id
    pve_iso_datastore_id       = var.pve_iso_datastore_id
    pve_disk_datastore_id      = var.pve_disk_datastore_id
    vm_disk_size               = var.vm_disk_size
    vm_agent_enabled           = var.vm_agent_enabled
    vm_memory                  = var.vm_memory
    vm_network_bridge          = var.vm_network_bridge
    vm_managed_tag             = var.vm_managed_tag
    vm_tags                    = var.vm_tags
    extra_butane_snippets      = var.extra_butane_snippets
    vm_id                      = var.vm_id
    node_name                  = var.node_name
    coreos_stream              = var.coreos_stream
  }))
}
resource "random_pet" "random_hostname" {
  keepers = {
    flat_hash = local.flat_hash
  }
}
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

  vga {
    type = var.vm_vga_type
  }

  serial_device {
    device = "socket"
  }

  memory {
    dedicated = var.vm_memory
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
