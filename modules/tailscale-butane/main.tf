# modules/tailscale-butane/main.tf
terraform {
  required_version = ">= 1.0"
}

# Create Butane snippet for tailscale-up systemd unit
locals {
  tailscale_extra_args = try(join(" ", var.tailscale_extra_args), "")
  execstartpost_lines = try(join("\n", [
    for cmd in var.late_commands : "ExecStartPost=${cmd}"
  ]), "")

  advertise_tags_args = (
    var.tailscale_tags != null && length(compact(var.tailscale_tags)) > 0
    ? "--advertise-tags=${join(",", compact(var.tailscale_tags))}"
    : ""
  )
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
resource "terraform_data" "butane_snippet_replaceable" {
  count = var.replace_when_key_changes ? 1 : 0

  input = local.tailscale_butane_snippet
  # No lifecycle block - will replace when input changes
}

resource "terraform_data" "butane_snippet_stable" {
  count = var.replace_when_key_changes ? 0 : 1

  input = local.tailscale_butane_snippet

  lifecycle {
    ignore_changes = [input]
  }
}
locals {
  butane_result = var.replace_when_key_changes ? terraform_data.butane_snippet_replaceable[0].output : terraform_data.butane_snippet_stable[0].output

}
output "butane_snippet" {
  value       = local.butane_result
  description = "butane snippet to bring up tailscale"
}