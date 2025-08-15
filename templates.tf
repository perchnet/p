module "debian13" {
  source = "github.com/b-/terraform-bpg-proxmox//modules/vm?ref=3cc1151"
  #source = "/home/bri/dev/terraform-proxmox-modules/modules/vm"

  efi = {
    storage = "zssd"
  }
  node = local.pve_node
  disks = [{
    storage = "zssd"
    download = {
      storage   = "zssd-files"
      filename  = "debian-13-generic-amd64.img" # Convert *.qcow2 image to *.img
      url       = "https://cloud.debian.org/images/cloud/trixie/20250806-2196/debian-13-generic-amd64-20250806-2196.qcow2"
      checksum  = "a7dfe434afc40afb0a791c777f3edba6b1a5c4b7315a61073fe5e34752d3bc5fd44ff67ef054eb4263687a97f7ce4896bf5bad5f216ef8b9d4a84541759e743d"
      algorithm = "sha512"
      overwrite = false
    }
  }]

  # VM Template Variables
  qemu_guest_agent = false
  vmid             = 9013
  name             = "debian13"
  tags             = ["terraform", "template", "debian"]
  #ci_vendor_data = "local:snippets/vendor-data.yaml"
}
module "ubuntu22" {
  source = "github.com/b-/terraform-bpg-proxmox//modules/vm?ref=3cc1151"
  #source = "/var/home/bri/dev/terraform-proxmox-modules/modules/vm"

  efi  = {}
  node = local.pve_node

  disks = [
    {
      storage = "zssd"
      download = {
        storage   = "zssd-files"
        url       = "https://cloud-images.ubuntu.com/releases/22.04/release-20240207/ubuntu-22.04-server-cloudimg-amd64.img" # Required
        checksum  = "7eb9f1480956af75359130cd41ba24419d6fd88d3af990ea9abe97c2f9459fda"                                       # Required
        algorithm = "sha256"                                                                                                 # Optional
        overwrite = false                                                                                                    # Optional
      }
      size = 20
    }
  ]
  # Image Variables

  # VM Template Variables
  qemu_guest_agent = false
  #vm_id       = 8022                                             # Required
  name = "ubuntu22" # Optional
  #description = "Terraform generated template on ${timestamp()}" # Optional
  tags = ["terraform", "template", "ubuntu"] # Optional
  #ci_vendor_data = "local:snippets/vendor-data.yaml"                # Optional
}
