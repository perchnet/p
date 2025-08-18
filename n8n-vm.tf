module "n8n_block_storage" {
  source  = "./modules/block-storage"
  node    = local.pve_node
  storage = "zssd"
  size    = 10
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
locals {
  n8n_user_data_map = {
    hostname            = "n8n-vm"
    ssh_authorized_keys = [data.onepassword_item.proxmox_ssh.public_key]
    mounts = [
      ["vda", "/srv", "ext4", "x-systemd.makefs,x-systemd.mount-timeout=2,nofail", "0", "2"]
    ]
    timezone = "America/New_York"

    write_files = [
      {
        path    = "/etc/systemd/system/tailscale-serve.service"
        content = <<-EOS
          [Unit]
          Description=Tailscale serve for n8n
          After=network.target tailscaled.service

          [Service]
          ExecStart=/usr/bin/tailscale serve 5678
          Restart=always

          [Install]
          WantedBy=multi-user.target
        EOS
      },
      {
        path    = "/etc/systemd/system/n8n.service"
        content = <<-EOS
          [Unit]
          Description=n8n automation
          After=network.target

          [Service]
          Type=simple
          User=n8n
          ExecStart=/usr/bin/n8n
          Restart=always
          Environment=PATH=/usr/bin:/usr/local/bin
          WorkingDirectory=/home/n8n

          [Install]
          WantedBy=multi-user.target
        EOS
      }
    ]

    users = [
      { name = "default" },
      {
        name   = "n8n"
        groups = "sudo"
        shell  = "/bin/bash"
        sudo   = ["ALL=(ALL) NOPASSWD:ALL"]
      }
    ]

    packages = [
      "curl",
      "bash",
      "sudo",
      "gnupg",
      "ca-certificates",
      "qemu-guest-agent"
    ]

    runcmd = [
      # format the tags as comma-separated string
      [
        "sh", "-c",
        "curl -fsSL https://tailscale.com/install.sh | sh"
      ],
      [
        "tailscale", "up",
        "--authkey", terraform_data.n8n_tskey_stable.output,
        "--accept-routes",
        "--accept-dns",
        "--ssh",
        "--advertise-tags=${join(",", local.ts_tags)}"
      ]
    ]

  }
}
module "n8n_vm" {
  source = "github.com/b-/terraform-bpg-proxmox//modules/vm?ref=e022451"
  #started = true
  scsihw = "virtio-scsi-single"
  cloudinit = {
    datastore_id     = "zssd-files"
    snippets_storage = "snippets"
    user_data        = <<-EOF
      #cloud-config
      ${yamlencode(local.n8n_user_data_map)}}
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
    },
    {
      storage   = module.block_storage.disk.datastore_id
      interface = "virtio0"
      size      = module.n8n_block_storage.disk.size
    }
  ]
  depends_on = [module.debian13]
}
