terraform {
  required_version = ">= 1.5"
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "2.1.2"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.79"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = ">= 0.21.1"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.2"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.5.0"
    }
  }
}
