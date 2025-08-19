terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.82.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  required_version = ">= 1.3.0"
}

locals {
  # Merge defaults with user-provided values
  images_with_defaults = {
    for name, config in var.images : name => {
      url                     = config.url
      file_name               = coalesce(config.file_name, basename(config.url)),
      content_type            = coalesce(config.content_type, var.content_type)
      datastore_id            = coalesce(config.datastore_id, var.datastore_id)
      node_name               = coalesce(config.node_name, var.node_name)
      checksum                = config.checksum
      checksum_algorithm      = coalesce(config.checksum_algorithm, var.checksum_algorithm)
      decompression_algorithm = try(coalesce(config.decompression_algorithm, var.decompression_algorithm), null)
      overwrite               = coalesce(config.overwrite, var.overwrite)
      overwrite_unmanaged     = coalesce(config.overwrite_unmanaged, var.overwrite_unmanaged)
      upload_timeout          = coalesce(config.upload_timeout, var.upload_timeout)
      verify                  = coalesce(config.verify, var.verify)
    }
  }
}

# Generate random 4-digit ID for each image
resource "random_id" "image_id" {
  for_each = local.images_with_defaults

  byte_length = 2 # 2 bytes = 4 hex characters
  keepers = {
    # Optional: Add keepers to regenerate ID when certain values change
    url = each.value.url
  }
}
resource "proxmox_virtual_environment_download_file" "images" {
  for_each = local.images_with_defaults

  # Split filename at first dot, insert random ID, then rejoin
  file_name = format("TFimg_%s-%s.%s",
    split(".", each.value.file_name)[0],
    random_id.image_id[each.key].hex,
    join(".", slice(split(".", each.value.file_name), 1, length(split(".", each.value.file_name))))
  )

  # Required arguments
  content_type = each.value.content_type
  datastore_id = each.value.datastore_id
  node_name    = each.value.node_name
  url          = each.value.url

  # Optional arguments - only set if not null


  checksum                = each.value.checksum
  checksum_algorithm      = each.value.checksum != null ? each.value.checksum_algorithm : null
  decompression_algorithm = each.value.decompression_algorithm
  overwrite               = each.value.overwrite
  overwrite_unmanaged     = each.value.overwrite_unmanaged
  upload_timeout          = each.value.upload_timeout
  verify                  = each.value.verify
}
