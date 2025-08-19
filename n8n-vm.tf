module "n8n_block_storage" {
  source  = "./modules/block-storage"
  node    = local.pve_node
  storage = "zssd"
  size    = 10
  name    = "n8n-block-storage"
}
locals {
  ts_tags = ["tag:web-ingress"]
}

resource "terraform_data" "n8n_tskey_stable" {
  input = sensitive(tailscale_tailnet_key.tailscale_key.key)
  lifecycle {
    ignore_changes       = [input]
    replace_triggered_by = [terraform_data.n8n_tskey_stable_replacement_hook]
  }
}
resource "terraform_data" "n8n_tskey_stable_replacement_hook" {
  input = [module.n8n_vm.creation_date]
}
module "n8n_vm" {
  source = "github.com/b-/terraform-bpg-proxmox//modules/vm?ref=8d9dd51"
  #started = true
  vcpu   = 4
  scsihw = "virtio-scsi-single"
  cloudinit = {
    datastore_id     = "zssd-files"
    snippets_storage = "snippets"
    user_data        = <<-EOF
      #cloud-config
      hostname: n8n-vm
      ssh_authorized_keys: ${jsonencode(data.onepassword_item.proxmox_ssh.public_key)}
      write_file:
        - path: /etc/fstab
          append: true
          content: |
            /dev/vda /srv ext4 x-systemd.makefs,x-systemd.mount-timeout=2,nofail 0 2
      timezone: America/New_York
      runcmd:
        - ['sh', '-c', 'curl -fsSL https://tailscale.com/install.sh | sh']
        - [ 'tailscale', 'up', '--authkey', ${terraform_data.n8n_tskey_stable.output},
            '--accept-routes',
            '--accept-dns',
            '--ssh',
            '--advertise-tags=${join(",", local.ts_tags)}'
          ]
        - [ '/usr/bin/env', 'HOME=/root','sh', '-c', 'curl -fsSL https://raw.githubusercontent.com/moghtech/komodo/main/scripts/setup-periphery.py | python3' ]
        - [ 'systemctl', 'enable', '--now', 'periphery' ]
        - [ 'tailscale', 'serve', '--bg', '8120' ]
        - [ 'sh', '-c', 'curl -fsSL https://get.docker.com | sh' ]
        - [ 'sh', '-c', 'echo "/dev/vda /srv ext4 x-systemd.makefs,x-systemd.mount-timeout=2,nofail 0 2" >> /etc/fstab' ]
        - [ 'systemctl', 'enable', '--now', 'docker' ]
      power_state:
        mode: reboot
        message: rebooting to run systemd.makefs
        timeout: 480
    EOF

  }
  qemu_guest_agent = false

  nics = [
    { ip_config = { ipv4 = { address = "dhcp" } } }
  ]
  node = local.pve_node
  name = "n8n-vm"
  clone = {
    template_node = local.pve_node
    template_id   = module.debian13.id
    full          = false
  }
  disks = [
    {
      storage   = "zssd"
      interface = "scsi0"
      size      = 10
    },
    {
      storage           = module.block_storage.disk.datastore_id
      path_in_datastore = module.block_storage.disk.id
      interface         = "virtio0"
      size              = module.n8n_block_storage.disk.size
    }
  ]
  depends_on = [module.debian13]
}
