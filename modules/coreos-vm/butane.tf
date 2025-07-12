locals {
  butanes = coalescelist(var.extra_butane_snippets, [
    templatefile("${path.module}/ct/autorebase.yaml.tftpl", {
      target_image = "ghcr.io/ublue-os/ucore-hci:stable"
    }),
  ])
}
# Butane Config for Fedora CoreOS
data "ct_config" "fedora-coreos-config" {
  content = templatefile("${path.module}/ct/fcos.yaml.tftpl", {
    message       = "Hello World!",
    hostname      = local.vm_hostname,
    sshkeys       = sensitive(var.vm_authorized_keys),
    username      = local.coreos_username,
    password_hash = sensitive(htpasswd_password.password_hash.bcrypt),
  })
  strict       = true
  pretty_print = true

  snippets = local.butanes
}
resource "htpasswd_password" "password_hash" {
  password = local.coreos_password
}

# Render as Ignition

locals {
  ignition_hash = substr(sha256(data.ct_config.fedora-coreos-config.rendered), 0, 8)
}

resource "proxmox_virtual_environment_file" "cloud_user_config" {
  content_type = "snippets"
  datastore_id = var.vm_snippets_datastore_id
  node_name    = var.pve_node
  source_raw {
    data      = sensitive(data.ct_config.fedora-coreos-config.rendered)
    file_name = "${local.ignition_hash}.butane-ci-user-data.ign"
  }
}
