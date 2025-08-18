# modules/coreos-vm/variables.tf
variable "username" {
  description = "initial username"
  type        = string
  default     = "core"
}
variable "password" {
  description = "initial user's password"
  type        = string
}

variable "pve_node" {
  description = "Proxmox VE node name"
  type        = string
  default     = "pve1"
}

variable "vm_name" {
  description = "VM name (defaults to random name)"
  type        = string
  default     = null
}
variable "vm_hostname" {
  description = "VM hostname (defaults to VM name)"
  type        = string
  default     = null
}
variable "vm_description" {
  description = "VM description"
  type        = string
  default     = "Managed by Terraform"
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
  description = "snippets datastore id"
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
  description = "ethernet bridge"
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
  description = "additional butane snippets to  include"
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

variable "coreos_img" {
  description = "Optional existing CoreOS image resource. If provided, the module will use this instead of downloading a new image."
  type = object({
    id = string
  })
  default = null
}
