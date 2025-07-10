terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "perchnet"

    workspaces {
      name = "proxmox"
    }

  }
}
