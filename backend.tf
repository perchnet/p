terraform {
  required_version = ">= 1.0"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "perchnet"

    workspaces {
      name = "proxmox"
    }

  }
}
