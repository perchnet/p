terraform {
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
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = ">= 0.21.1"
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
}
data "onepassword_vault" "perchnet_vault" {
  name = "perchnet"
}

data "onepassword_item" "proxmox_ssh" {
  vault = local.perchnet_vault
  title = "proxmox-ssh"
}

locals {
  # Proxmox connection settings
  pve_host = "pve1.shark-perch.ts.net"
  pve_port = 443
  pve_node = "pve1"

  # Credentials (fetched from OnePassword or any secrets manager)
  pve_api_username = data.onepassword_item.proxmox_api.username
  pve_api_password = sensitive(data.onepassword_item.proxmox_api.password)
  pve_ssh_username = data.onepassword_item.proxmox_ssh.username
  pve_ssh_password = sensitive(data.onepassword_item.proxmox_ssh.password)

  # Full endpoint
  pve_endpoint = "https://${local.pve_host}:${local.pve_port}"
  pve_insecure = false

  # SSH address (same as host for most use cases)
  pve_ssh_address = local.pve_host
}
# Provide SSH access to all nodes as well as an admin API token
provider "proxmox" {
  endpoint = local.pve_endpoint
  insecure = local.pve_insecure

  username = local.pve_api_username
  password = local.pve_api_password

  ssh {
    username = local.pve_ssh_username
    password = local.pve_ssh_password

    #private_key = data.external.proxmox_ssh_pem.result["pem_key"]
    node {
      name    = local.pve_node
      address = local.pve_ssh_address
    }
  }
}
