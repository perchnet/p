locals {
  pve_node       = "pve1"
  vm_name        = "ubuntu-dev"
  ci_datastore   = "zssd-files"
  disk_datastore = "zssd"
  tpm_datastore  = local.ci_datastore
  ipv4_address   = "dhcp"
}
resource "proxmox_virtual_environment_vm" "ubuntu_dev_vm" {
  name        = "ubuntu-dev"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu", "tailscale", "docker", "dev"]

  node_name = local.pve_node
  #vm_id     = 4321

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
  }
  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

  #   startup {
  #     order      = "3"
  #     up_delay   = "60"
  #     down_delay = "60"
  #   }

  cpu {
    cores = 3
    type  = "host"
  }

  memory {
    dedicated = 4096
    floating  = 4096 # set equal to dedicated to enable ballooning
  }

  disk {
    datastore_id = local.disk_datastore
    file_format  = "raw"
    import_from  = var.import_from_image
    interface    = "scsi0"
  }

  initialization {
    datastore_id = local.ci_datastore
    ip_config {
      ipv4 {
        address = local.ipv4_address
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      password = random_password.ubuntu_vm_password.result
      username = "ubuntu"
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    datastore_id = "zssd"
    version      = "v2.0"
  }

  serial_device {}

  virtiofs {
    mapping   = "rust-root"
    cache     = "always"
    direct_io = true
  }
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_file.cloud_config]
  }
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "snippets"
  node_name    = local.pve_node

  source_raw {
    data = <<-EOF
      #cloud-config
      hostname: test-ubuntu
      timezone: America/New_York
      users:
        - default
        - name: ubuntu
          groups:
            - sudo
          shell: /bin/bash
          passwd: ${trimspace(bcrypt(resource.random_password.ubuntu_vm_password.result))}
          ssh_authorized_keys:
            - ${trimspace(resource.random_pet.ubuntu_pet.keepers.ssh_public_key)}
          sudo: ALL=(ALL) NOPASSWD:ALL
      package_update: true
      apt:
        sources:
          docker.list:
            source: deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable
            keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

      packages:
        - qemu-guest-agent
        - net-tools
        - curl
      runcmd:
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "example.cloud-config.yaml"
  }
}

resource "random_pet" "ubuntu_pet" {
  keepers = {
    ssh_public_key = tls_private_key.ubuntu_vm_key.public_key_openssh
  }
}

resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "ED25519"
  #rsa_bits  = 2048
}

output "ubuntu_vm_password" {
  value     = random_password.ubuntu_vm_password.result
  sensitive = true
}

output "ubuntu_vm_private_key" {
  value     = tls_private_key.ubuntu_vm_key.private_key_pem
  sensitive = true
}

output "ubuntu_vm_public_key" {
  value = tls_private_key.ubuntu_vm_key.public_key_openssh
}

# resource "onepassword_item" "ssh_key" {
#   category    = "ssh_key"
#   vault       = local.vault
#   private_key = tls_private_key.ubuntu_vm_key.private_key_pem
# }
locals {
  vault_name = "perchnet"
  vault      = data.onepassword_vault.perchnet_vault.uuid
}
data "onepassword_vault" "perchnet_vault" {
  name = local.vault_name
}
