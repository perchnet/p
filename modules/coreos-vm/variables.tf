variable "username" {
  description = "initial username"
  type        = string
  default     = "core"
}
variable "password" {
  description = "initial user's password"
  type        = string
}

variable "stream" {
  description = "The CoreOS stream name"
  type        = string
  default     = "testing" # proxmoxve isn't in stable yet
}

variable "pve_node" {
  description = "Proxmox VE node name"
  type        = string
  default     = "pve1"
}

variable "vm_name" {
  description = "VM name (if empty it will use a random name)"
  type        = string
  default     = null
}

variable "vm_hostname" {
  description = "VM hostname (if different from vm_name)"
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
variable "proxmox_host" {
  description = "Proxmox server hostname or IP address"
  type        = string
}

variable "proxmox_port" {
  description = "Proxmox server port"
  type        = number
  default     = 8006
}

variable "vm_id" {
  description = "Virtual machine ID to retrieve UUID for"
  type        = number
  default     = null
}

variable "node_name" {
  description = "Proxmox node name where the VM is located"
  type        = string
}

variable "pve_api_token" {
  description = "Proxmox API token (format: PVEAPIToken=user@realm!tokenid=secret)"
  type        = string
  default     = null
  sensitive   = true
}

variable "pve_api_token_id" {
  description = "Proxmox API token ID (format: user@realm!tokenid)"
  type        = string
  default     = null
  sensitive   = true
}

variable "pve_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  default     = null
  sensitive   = true
}

variable "pve_username" {
  description = "Proxmox username (format: user@realm)"
  type        = string
  default     = null
  sensitive   = true
}

variable "pve_password" {
  description = "Proxmox password"
  type        = string
  default     = null
  sensitive   = true
}

variable "pve_ssh_username" {
  description = "Proxmox ssh username (must be PAM)"
  type        = string
  default     = null
  sensitive   = true
}

variable "pve_ssh_password" {
  description = "Proxmox ssh password"
  type        = string
  default     = null
  sensitive   = true
}

variable "pve_ssh_address" {
  description = "Proxmox node ssh address"
  type        = string
  default     = null
  sensitive   = true
}

variable "pve_private_key" {
  description = "Proxmox ssh key"
  type        = string
  default     = null
  sensitive   = true
}

variable "verify_ssl" {
  description = "Whether to verify SSL certificates"
  type        = bool
  default     = true
}
