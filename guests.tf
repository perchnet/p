module "block_storage" {
  source  = "./modules/block-storage"
  node    = local.pve_node
  storage = "zssd"
  size    = 1
}
locals {
  debian_vm_name = "vm-debian13-minimal"                          # optional
  ci_ssh_keys    = [data.onepassword_item.proxmox_ssh.public_key] # optional, add SSH key to "default" user
}

resource "terraform_data" "tailscale_auth_key_stable" {
  input = sensitive(tailscale_tailnet_key.tailscale_key.key)
  lifecycle {
    ignore_changes = [input]
  }
}
module "vm_minimal_config" {
  source = "github.com/b-/terraform-bpg-proxmox//modules/vm?ref=97c67aa"
  #started = true
  scsihw = "virtio-scsi-single"
  cloudinit = {
    datastore_id     = "zssd-files"
    snippets_storage = "snippets"
    user_data        = <<-EOF
      #cloud-config
      hostname: ${local.debian_vm_name}
      ssh_authorized_keys: ${jsonencode(local.ci_ssh_keys)}
      timezone: America/New_York
      packages:
            - qemu-guest-agent
      runcmd:
        - ['sh', '-c', 'curl -fsSL https://tailscale.com/install.sh | sh']
        - tailscale up --authkey ${terraform_data.tailscale_auth_key_stable.output} --accept-routes --accept-dns --ssh
    EOF
  }
  qemu_guest_agent = false

  nics = [
    { ip_config = { ipv4 = { address = "dhcp" } } }
  ]
  node = local.pve_node
  name = local.debian_vm_name
  clone = {
    template_node = local.pve_node
    template_id   = module.debian13.id
  }
  disks = [
    {
      storage   = "zssd"
      interface = "scsi0"
      size      = 10
    }, module.block_storage.disk
  ]
  depends_on = [module.debian13]
}

resource "tailscale_tailnet_key" "tailscale_key" {
  reusable      = true
  ephemeral     = false               # Keep node when offline
  preauthorized = true                # Auto-authorize
  expiry        = 600                 #local.rotation_seconds
  tags          = ["tag:web-ingress"] #local.tailscale_tags
  #  lifecycle {
  #    replace_triggered_by = [time_rotating.rotate_tailnet_key]
  #  }
}
