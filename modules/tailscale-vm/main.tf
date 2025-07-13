# modules/tailscale-vm/main.tf
terraform {
  required_version = ">= 1.0"
}

# Create a single-use, short-lived Tailscale auth key
module "tailscale_auth_key" {
  source = "../tailscale-tailnet-key"

  description          = "Auth key for ${var.tailscale_hostname}"
  reusable             = false # Single-use key
  ephemeral            = false # Keep node when offline
  preauthorized        = true  # Auto-authorize
  expiry_seconds       = var.tailscale_auth_key_expiry_hours * 3600
  tags                 = var.tailscale_tags
  auto_generate_suffix = true # Ensure uniqueness
}

# Create Butane snippet for Tailscale systemd unit
locals {
  tailscale_butane_snippet = <<-EOF
    variant: fcos
    version: 1.5.0
    systemd:
      units:
        - name: tailscale-up.service
          enabled: true
          contents: |
            [Unit]
            Description=Connect to Tailscale
            After=network-online.target tailscaled.service
            Wants=network-online.target
            Requires=tailscaled.service

            [Service]
            Type=oneshot
            RemainAfterExit=yes
            ExecStart=/usr/bin/tailscale up --authkey=${module.tailscale_auth_key.key} --hostname=${var.tailscale_hostname}
            ExecStartPost=/bin/sh -c 'echo "Tailscale connected successfully" | systemd-cat -t tailscale-up'
            StandardOutput=journal
            StandardError=journal

            [Install]
            WantedBy=multi-user.target
EOF

  # Combine the Tailscale snippet with any additional snippets
  all_butane_snippets = concat([local.tailscale_butane_snippet], var.extra_butane_snippets)
}

# Create the CoreOS VM with Tailscale configuration
module "coreos_vm" {
  source = "../coreos-vm"

  # VM configuration
  username                   = var.username
  password                   = var.password
  pve_node                   = var.pve_node
  vm_description             = var.vm_description
  vm_vga_type                = var.vm_vga_type
  vm_authorized_keys         = var.vm_authorized_keys
  vm_cloud_init_datastore_id = var.vm_cloud_init_datastore_id
  vm_snippets_datastore_id   = var.vm_snippets_datastore_id
  pve_iso_datastore_id       = var.pve_iso_datastore_id
  pve_disk_datastore_id      = var.pve_disk_datastore_id
  vm_disk_size               = var.vm_disk_size
  vm_agent_enabled           = var.vm_agent_enabled
  vm_memory                  = var.vm_memory
  vm_network_bridge          = var.vm_network_bridge
  vm_managed_tag             = var.vm_managed_tag
  vm_tags                    = concat(var.vm_tags, ["tailscale"])
  vm_id                      = var.vm_id
  node_name                  = var.node_name
  coreos_stream              = var.coreos_stream
  coreos_img                 = var.coreos_img

  # Include Tailscale butane snippet
  extra_butane_snippets = local.all_butane_snippets
}
