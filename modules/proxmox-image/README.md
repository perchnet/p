```hcl
# Basic usage with minimal configuration
module "basic_images" {
  source = "./modules/proxmox-image"

  default_datastore_id = "local"
  default_node_name    = "pve1"

  images = {
    debian_bookworm = {
      url       = "https://cloud.debian.org/images/cloud/bookworm/20250428-2096/debian-12-nocloud-amd64-20250428-2096.qcow2"
      file_name = "debian-12-nocloud-amd64.qcow2"
      checksum  = "dab5547daa93c45213970cd137826f671ae4b2f8b8f016398538e78a97080d5dffb79c9e9e314031361257f145ba9a3ef057a63e5212135c699495085951eb25"
      checksum_algorithm = "sha512"
    }

    ubuntu_jammy = {
      url       = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
      file_name = "ubuntu-22.04-server-cloudimg-amd64.img"
      # Uses defaults for everything else
    }
  }
}

# Advanced usage with per-image overrides
module "advanced_images" {
  source = "./modules/proxmox-image"

  # Module-level defaults
  default_datastore_id         = "local"
  default_node_name           = "pve1"
  default_content_type        = "iso"
  default_checksum_algorithm  = "sha256"
  default_decompress          = true
  default_overwrite           = true
  default_overwrite_unmanaged = false
  default_upload_timeout      = 3600
  default_verify  = true

  images = {
    debian_bookworm = {
      url       = "https://cloud.debian.org/images/cloud/bookworm/20250428-2096/debian-12-nocloud-amd64-20250428-2096.qcow2"
      file_name = "debian-12-nocloud-amd64.qcow2"
      checksum  = "dab5547daa93c45213970cd137826f671ae4b2f8b8f016398538e78a97080d5dffb79c9e9e314031361257f145ba9a3ef057a63e5212135c699495085951eb25"
      checksum_algorithm = "sha512"
    }

    ubuntu_jammy = {
      url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
      file_name    = "ubuntu-22.04-server-cloudimg-amd64.img"
      node_name    = "pve2"  # Override default node
      datastore_id = "nvme-storage"  # Override default datastore
    }

    centos_stream = {
      url                = "https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
      file_name         = "CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
      node_name         = "pve3"
      upload_timeout    = 7200  # 2 hours for large file
      verify = false  # If needed for specific URLs
    }

    proxmox_container_template = {
      url          = "http://download.proxmox.com/images/system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
      file_name    = "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
      content_type = "vztmpl"  # Container template
      decompress   = false     # Keep compressed
    }
  }
}

# Multi-node deployment
module "multi_node_images" {
  source = "./modules/proxmox-image"

  default_datastore_id = "shared-storage"
  default_node_name    = "pve1"

  images = {
    # Download to different nodes
    debian_pve1 = {
      url       = "https://cloud.debian.org/images/cloud/bookworm/20250428-2096/debian-12-nocloud-amd64-20250428-2096.qcow2"
      file_name = "debian-12-nocloud-amd64.qcow2"
      node_name = "pve1"
    }

    debian_pve2 = {
      url       = "https://cloud.debian.org/images/cloud/bookworm/20250428-2096/debian-12-nocloud-amd64-20250428-2096.qcow2"
      file_name = "debian-12-nocloud-amd64.qcow2"
      node_name = "pve2"
    }

    debian_pve3 = {
      url       = "https://cloud.debian.org/images/cloud/bookworm/20250428-2096/debian-12-nocloud-amd64-20250428-2096.qcow2"
      file_name = "debian-12-nocloud-amd64.qcow2"
      node_name = "pve3"
    }
  }
}

# Accessing outputs
output "image_info" {
  value = {
    all_images       = module.basic_images.images
    image_ids        = module.basic_images.image_ids
    image_files      = module.basic_images.image_files
    successful_downloads = module.basic_images.successful_downloads
    total_size       = module.basic_images.total_size
  }
}

# Using images in VM modules
module "vm_from_downloaded_image" {
  source = "./modules/proxmox-vm"

  # Pass the downloaded image resource
  existing_image = module.basic_images.images["debian_bookworm"]
  vm_name        = "test-vm"
}

# Or reference by ID
resource "proxmox_virtual_environment_vm" "example" {
  name      = "example-vm"
  node_name = "pve1"

  disk {
    datastore_id = "local-lvm"
    file_id      = module.basic_images.image_ids["debian_bookworm"]
    interface    = "virtio0"
  }
}
```
