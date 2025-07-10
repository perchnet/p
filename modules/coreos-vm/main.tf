terraform {
  required_providers {
    ct = { # CoreOS Transpiler
      source  = "poseidon/ct"
      version = "0.13.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.79"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

locals {
  # cloud_init_datastore_id = "zssd-files"
  coreos_platform = "proxmoxve"
  metadata        = jsondecode(data.http.coreos_stable_metadata.response_body)

  coreos_proxmoxve_stable = local.metadata.architectures.x86_64.artifacts.proxmoxve.formats["qcow2.xz"].disk
  download_url            = local.coreos_proxmoxve_stable.location
  download_sum            = local.coreos_proxmoxve_stable.sha256
  coreos_username         = var.username
  coreos_password         = var.password

  coreos_img_filename = "coreos_${var.stream}_${local.coreos_platform}_${random_string.random_vm_id.id}.qcow2.xz.img"

  vm_name     = coalesce(var.vm_name, random_pet.random_hostname.id)
  vm_hostname = coalesce(var.vm_hostname, vm_name)


  node = var.pve_node
}
resource "random_string" "random_vm_id" {
  keepers = {
    uuid = proxmox_virtual_environment_vm.coreos_vm.smbios[0].uuid
  }
  length  = 6
  special = false
  numeric = true
  upper   = false
  lower   = true
}

resource "random_pet" "random_hostname" {
  keepers = {
    uuid = proxmox_virtual_environment_vm.coreos_vm.smbios[0].uuid
  }
}

data "http" "coreos_stable_metadata" {
  url = "https://builds.coreos.fedoraproject.org/streams/${var.stream}.json"
}
resource "proxmox_virtual_environment_download_file" "coreos_img" {
  content_type = "iso"
  datastore_id = var.pve_iso_datastore_id
  node_name    = local.node

  url                = local.download_url
  checksum           = local.download_sum
  checksum_algorithm = "sha256"

  file_name               = local.coreos_img_filename
  decompression_algorithm = "zst"
}
resource "proxmox_virtual_environment_vm" "coreos_vm" {
  # This must be the name of your Proxmox node within Proxmox
  node_name   = local.node
  name        = var.vm_name
  description = var.vm_description

  tags = concat(var.vm_tags, [var.vm_managed_tag])

  started = true

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
    size         = 32
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

# Butane Config for Fedora CoreOS
data "ct_config" "fedora-coreos-config" {
  content = templatefile("${path.module}/ct/fcos.yaml", {
    message  = "Hello World!",
    sshkeys  = var.vm_authorized_keys,
    username = var.username,
    password = var.password,
  })
  strict       = true
  pretty_print = true

  snippets = [
    file("${path.module}/ct/fcos-snippet.yaml"),
  ]
}

# Render as Ignition
resource "proxmox_virtual_environment_file" "cloud_user_config" {
  content_type = "snippets"
  datastore_id = var.vm_snippets_datastore_id
  node_name    = var.pve_node

  source_raw {
    data      = data.ct_config.fedora-coreos-config.rendered
    file_name = "${local.vm_name}.${random_string.random_vm_id.id}.butane-ci-user-data.ign"
  }
}
