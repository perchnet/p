terraform {
  required_version = ">=1.5.0"
  required_providers {
    slugify = {
      source  = "public-cloud-wl/slugify"
      version = ">=0.1.1"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.82.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.13.1"
    }
  }
}
