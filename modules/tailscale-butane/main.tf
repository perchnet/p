# modules/tailscale-butane/main.tf
terraform {
  required_version = ">= 1.0"
}

# Create Butane snippet for tailscale-up systemd unit
locals {
  tailscale_extra_args = var.tailscale_extra_args
  execstartpost_lines = join("\n", [
    for cmd in var.late_commands : "ExecStartPost=${cmd}"
  ])
  advertise_tags_args = join(" ", [
    for tag in var.tailscale_tags : "--advertise-tag=${tag}"
  ])
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
            ExecStart=/usr/bin/tailscale up --authkey=${var.tailscale_auth_key} ${local.advertise_tags_args} ${local.tailscale_extra_args}
            ExecStartPost=/bin/sh -c 'echo "Tailscale connected successfully" | systemd-cat -t tailscale-up'
            ${local.execstartpost_lines}
            StandardOutput=journal+console
            StandardError=journal+console

            [Install]
            WantedBy=multi-user.target
  EOF
}
output "butane_snippet" {
  value       = local.tailscale_butane_snippet
  description = "butane snippet to bring up tailscale"
}