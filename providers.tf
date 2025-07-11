terraform {
  # backend "s3" {
  #   bucket = "tfstate"
  #   key    = "talos-bootstrap.tfstate"
  #   region = "us-east"

  #   endpoints = {
  #     s3 = "https://s3.vaughn.sh"
  #   }

  #   skip_credentials_validation = true
  #   skip_requesting_account_id = true
  #   skip_metadata_api_check = true
  #   skip_region_validation = true
  #   use_path_style = true
  # }

  required_providers {
    ct = { # CoreOS Transpiler
      source  = "poseidon/ct"
      version = "0.13.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "2.1.2"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.79"
    }
  }
}

variable "onepassword_sdk_token" {
  type      = string
  sensitive = true
}

provider "onepassword" {
  service_account_token = var.onepassword_sdk_token
  #account = "my.1password.com"
}

data "onepassword_item" "proxmox_api" {
  vault = local.perchnet_vault
  title = "proxmox-api"
}

locals {
  perchnet_vault = data.onepassword_vault.perchnet_vault.uuid
  pve_address    = "pve1.shark-perch.ts.net"
  pve_endpoint   = "https://${local.pve_address}"
}
data "onepassword_vault" "perchnet_vault" {
  name = "perchnet"
}

data "onepassword_item" "proxmox_token" {
  vault = local.perchnet_vault
  title = "proxmox-api-token"
}

data "onepassword_item" "proxmox_ssh" {
  vault = local.perchnet_vault
  title = "proxmox-ssh"
}

# Provide SSH access to all nodes as well as an admin API token
provider "proxmox" {
  endpoint = "https://pve1.shark-perch.ts.net"
  insecure = false
  #api_token = data.onepassword_item.proxmox_token.credential
  username = data.onepassword_item.proxmox_api.username
  password = data.onepassword_item.proxmox_api.password

  ssh {
    #agent    = true
    node {
      name    = var.node
      address = local.pve_address
    }
    username = data.onepassword_item.proxmox_ssh.username
    password = data.onepassword_item.proxmox_ssh.password
  }
}
