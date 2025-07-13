variable "images" {
  description = "Map of image configurations to download"
  type = map(object({
    # Required fields
    url = string

    # Optional fields with defaults
    content_type            = optional(string, "iso")
    datastore_id            = optional(string)
    node_name               = optional(string)
    checksum                = optional(string)
    checksum_algorithm      = optional(string, "sha256")
    decompression_algorithm = optional(string)
    overwrite               = optional(bool, true)
    overwrite_unmanaged     = optional(bool, false)
    upload_timeout          = optional(number, 600)

    # Advanced optional fields
    file_name = optional(string)
    verify    = optional(bool, true)
  }))

  validation {
    condition = alltrue([
      for name, image in var.images :
      image.url != null
    ])
    error_message = "Each image must have 'url' specified."
  }

  validation {
    condition = alltrue([
      for name, image in var.images :
      contains(["iso", "import", "vztmpl"], coalesce(image.content_type, "iso"))
    ])
    error_message = "Content type must be either 'iso', 'import', or 'vztmpl'."
  }

  validation {
    condition = alltrue([
      for name, image in var.images :
      image.checksum == null || contains(["md5", "sha1", "sha224", "sha256", "sha384", "sha512"], coalesce(image.checksum_algorithm, "sha256"))
    ])
    error_message = "Checksum algorithm must be one of: md5, sha1, sha224, sha256, sha384, sha512."
  }

  validation {
    condition = alltrue([
      for name, image in var.images :
      image.upload_timeout == null || (image.upload_timeout >= 1 && image.upload_timeout <= 86400)
    ])
    error_message = "Upload timeout must be between 1 and 86400 seconds (10 minutes)."
  }
}

variable "datastore_id" {
  description = "Datastore ID for storing downloaded images"
  type        = string
  default     = "local"

  validation {
    condition     = length(var.datastore_id) > 0
    error_message = "Datastore ID cannot be empty."
  }
}

variable "node_name" {
  description = "Proxmox cluster node name for downloading images"
  type        = string
  default     = "pve"

  validation {
    condition     = length(var.node_name) > 0
    error_message = "Node name cannot be empty."
  }
}

variable "content_type" {
  description = "Content type for images"
  type        = string
  default     = "iso"

  validation {
    condition     = contains(["iso", "import", "vztmpl"], var.content_type)
    error_message = "Content type must be either 'iso', 'import', or 'vztmpl'."
  }
}

variable "checksum_algorithm" {
  description = "Checksum algorithm"
  type        = string
  default     = "sha256"

  validation {
    condition     = contains(["md5", "sha1", "sha224", "sha256", "sha384", "sha512"], var.checksum_algorithm)
    error_message = "Checksum algorithm must be one of: md5, sha1, sha224, sha256, sha384, sha512."
  }
}

variable "decompression_algorithm" {
  description = "Decompress downloaded files"
  type        = string
  default     = null
  validation {
    condition     = var.decompression_algorithm == null || contains(["gz", "lzo", "zst", "bz2"], var.decompression_algorithm)
    error_message = "value must be either 'gz', 'lzo', 'zst', or 'bz2'"

  }
}

variable "overwrite" {
  description = "Overwrite existing files"
  type        = bool
  default     = true
}

variable "overwrite_unmanaged" {
  description = "Overwrite unmanaged files"
  type        = bool
  default     = false
}

variable "upload_timeout" {
  description = "Upload timeout in seconds"
  type        = number
  default     = 600

  validation {
    condition     = var.upload_timeout == null || (var.upload_timeout >= 1 && var.upload_timeout <= 86400)
    error_message = "Upload timeout must be between 1 and 86400 seconds."
  }
}

variable "verify_certificate" {
  description = "Verify SSL certificates when downloading"
  type        = bool
  default     = true
}
