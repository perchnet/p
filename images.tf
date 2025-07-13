locals {
  datastore_id  = "zssd-files"
  node_name     = "pve1"
  coreos_stream = "testing"
}

module "coreos_metadata" {
  source = "github.com/perchnet/terraform-module-coreos-metadata?ref=c700d78"

  platform = "proxmoxve"
  stream   = local.coreos_stream
}

module "debian_bookworm_image" {
  source = "./modules/proxmox-image"

  datastore_id        = local.datastore_id
  node_name           = local.node_name
  overwrite           = true
  overwrite_unmanaged = true

  images = {
    debian_bookworm = {
      file_name          = "debian-12-nocloud-amd64.qcow2.img"
      url                = "https://cloud.debian.org/images/cloud/bookworm/20250428-2096/debian-12-nocloud-amd64-20250428-2096.qcow2"
      checksum           = "38557e6d8e8738392dc5959b679c4567dbe4ce6475aaa3ba054caab4f1e4f90876c49f6e20be79a5a151105e121f2e19a51319bdb0a223c90fea11b0a13deb25"
      checksum_algorithm = "sha512" # Override default
    }
  }
}

module "ubuntu_jammy_image" {
  source = "./modules/proxmox-image"

  datastore_id        = local.datastore_id
  node_name           = local.node_name
  overwrite           = true
  overwrite_unmanaged = true

  images = {
    ubuntu_jammy = {
      file_name = "ubuntu-22.04-server-cloudimg-amd64.img"
      url       = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
      # Uses defaults for content_type and checksum_algorithm
    }
  }
}

module "debian_trixie_image" {
  source = "./modules/proxmox-image"

  datastore_id        = local.datastore_id
  node_name           = local.node_name
  overwrite           = true
  overwrite_unmanaged = true

  images = {
    debian_trixie = {
      file_name          = "debian-13-genericcloud-amd64.qcow2.img"
      url                = "https://cloud.debian.org/images/cloud/trixie/daily/20250619-2148/debian-13-generic-amd64-daily-20250619-2148.qcow2"
      checksum           = "046d9691b1a6026fd457b85c85476fa721249dd9379e23ab877bb34b2d6fa662994b03a23ffe7b527c5421cb1a69e81b6873c82f0e1ac9403bbaad263fffd3d8"
      checksum_algorithm = "sha512"
    }
  }
}

module "ubuntu_noble_cloud_image" {
  source = "./modules/proxmox-image"

  datastore_id        = local.datastore_id
  node_name           = local.node_name
  overwrite           = true
  overwrite_unmanaged = true

  images = {
    ubuntu_noble_cloud_image = { # TODO: use renovate to update the checksum
      file_name          = "ubuntu-24.04-cloudimg-amd64.qcow.iso"
      url                = "https://cloud-images.ubuntu.com/noble/20250610/noble-server-cloudimg-amd64.img"
      checksum           = "92d2c4591af9a82785464bede56022c49d4be27bde1bdcf4a9fccc62425cda43"
      checksum_algorithm = "sha256"
    }
  }
}

module "ubuntu_jammy_cloud_image" {
  source = "./modules/proxmox-image"

  datastore_id        = local.datastore_id
  node_name           = local.node_name
  overwrite           = true
  overwrite_unmanaged = true

  images = {
    ubuntu_jammy_cloud_image = {
      url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    }
  }
}

module "coreos_image" {
  source = "./modules/proxmox-image"

  datastore_id        = local.datastore_id
  node_name           = local.node_name
  overwrite           = true
  overwrite_unmanaged = true

  images = {
    coreos_img = {
      url                = module.coreos_metadata.download_url
      checksum           = module.coreos_metadata.download_sum
      checksum_algorithm = "sha256"

      # proxmox won't download it unless you say it ends in .img
      file_name               = "${module.coreos_metadata.coreos_img_filename}.img"
      decompression_algorithm = "zst"
    }
  }
}
