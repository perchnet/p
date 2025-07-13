terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.38.0"
    }
  }
  required_version = ">= 1.3.0"
}

locals {
  # Merge defaults with user-provided values
  images_with_defaults = {
    for name, config in var.images : name => {
      url                     = config.url
      file_name               = config.file_name
      content_type            = coalesce(config.content_type, var.content_type)
      datastore_id            = coalesce(config.datastore_id, var.datastore_id)
      node_name               = coalesce(config.node_name, var.node_name)
      checksum                = config.checksum
      checksum_algorithm      = coalesce(config.checksum_algorithm, var.checksum_algorithm)
      decompression_algorithm = coalesce(config.decompression_algorithm, var.decompression_algorithm, null)
      overwrite               = coalesce(config.overwrite, var.overwrite)
      overwrite_unmanaged     = coalesce(config.overwrite_unmanaged, var.overwrite_unmanaged)
      upload_timeout          = coalesce(config.upload_timeout, var.upload_timeout)
      verify                  = coalesce(config.verify, var.verify)
    }
  }
}

resource "proxmox_virtual_environment_download_file" "images" {
  for_each = local.images_with_defaults

  # Required arguments
  content_type = each.value.content_type
  datastore_id = each.value.datastore_id
  node_name    = each.value.node_name
  url          = each.value.url

  # Optional arguments - only set if not null
  file_name               = each.value.file_name
  checksum                = each.value.checksum
  checksum_algorithm      = each.value.checksum != null ? each.value.checksum_algorithm : null
  decompression_algorithm = each.value.decompression_algorithm
  overwrite               = each.value.overwrite
  overwrite_unmanaged     = each.value.overwrite_unmanaged
  upload_timeout          = each.value.upload_timeout
  verify                  = each.value.verify
}