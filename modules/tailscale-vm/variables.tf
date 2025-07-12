# modules/tailscale-vm/variables.tf

# Tailscale-specific variables
variable "tailscale_hostname" {
  description = "Hostname for the Tailscale node (will be used as auth key description)"
  type        = string

  validation {
    condition     = length(var.tailscale_hostname) > 0
    error_message = "Tailscale hostname cannot be empty."
  }
}

variable "tailscale_tags" {
  description = "List of tags to apply to the Tailscale node"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for tag in var.tailscale_tags : can(regex("^tag:[a-zA-Z][a-zA-Z0-9_-]*$", tag))
    ])
    error_message = "Tags must start with tag: and contain only letters, numbers, underscores, and hyphens."
  }
}

variable "tailscale_auth_key_expiry_hours" {
  description = "Number of hours until the Tailscale auth key expires (max 24 hours for single-use)"
  type        = number
  default     = 1

  validation {
    condition     = var.tailscale_auth_key_expiry_hours > 0 && var.tailscale_auth_key_expiry_hours <= 24
    error_message = "Auth key expiry must be between 1 and 24 hours for single-use keys."
  }
}

# VM-specific variables (pass-through from coreos-vm module)
variable "username" {
  description = "Initial username for the VM"
  type        = string
  default     = "core"
}

variable "password" {
  description = "Initial user's password"
  type        = string
}

variable "pve_node" {
  description = "Proxmox VE node name"
  type        = string
  default     = "pve1"
}

variable "vm_description" {
  description = "VM description"
  type        = string
  default     = "Tailscale VM managed by Terraform"
}

variable "vm_vga_type" {
  description = "VM VGA type"
  type        = string
  default     = "serial0"
}

variable "vm_authorized_keys" {
  description = "Authorized SSH keys"
  type        = list(string)
  default     = []
}

variable "vm_cloud_init_datastore_id" {
  description = "Cloud init datastore ID, should support block images"
  type        = string
  default     = "local-zfs"
}

variable "vm_snippets_datastore_id" {
  description = "Snippets datastore id"
  type        = string
  default     = "snippets"
}

variable "pve_iso_datastore_id" {
  description = "ISO datastore ID"
  type        = string
  default     = "local"
}

variable "pve_disk_datastore_id" {
  description = "Disk datastore ID"
  type        = string
  default     = "local"
}

variable "vm_disk_size" {
  description = "VM disk size in GB"
  type        = number
  default     = 20
}

variable "vm_agent_enabled" {
  description = "VM agent enabled"
  type        = bool
  default     = false
}

variable "vm_memory" {
  description = "VM memory in MB"
  type        = number
  default     = 2048
}

variable "vm_network_bridge" {
  description = "Ethernet bridge"
  type        = string
  default     = "vmbr0"
}

variable "vm_managed_tag" {
  description = "VM managed tag"
  type        = string
  default     = "terraform"
}

variable "vm_tags" {
  description = "VM tags"
  type        = list(string)
  default     = []
}

variable "extra_butane_snippets" {
  description = "Additional butane snippets to include"
  type        = list(string)
  default     = []
}

variable "vm_id" {
  description = "Virtual machine ID"
  type        = number
  default     = null
}

variable "node_name" {
  description = "Proxmox node name where the VM is located"
  type        = string
}

variable "coreos_stream" {
  description = "CoreOS stream"
  type        = string
  default     = "testing"
}