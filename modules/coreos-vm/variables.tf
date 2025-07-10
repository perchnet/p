variable "username" {
  description = "initial username"
  type        = string
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

variable "platform" {
  description = "The CoreOS platform name"
  type        = string
  default     = "proxmoxve"
}

variable "pve_node" {
  description = "Proxmox VE node name"
  type        = string
  default     = "pve1"
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "coreos-vm"
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

variable "vm_serial_enabled" {
  description = "vm serial port"
  type        = bool
  default     = true
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
  type = string
  default = "snippets"
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

variable "vm_scsi_type" {
  description = "VM scsi type"
  type        = string
  default     = "virtio-scsi-single"
}

variable "vm_started" {
  description = "VM started"
  type        = bool
  default     = true
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

variable "vm_cpu_cores" {
  description = "VM CPU cores"
  type        = number
  default     = 2
}

variable "vm_cpu_sockets" {
  description = "VM CPU sockets"
  type        = number
  default     = 1
}

variable "vm_network_bridge" {
  description = "ethernet bridge"
  type = string
  default = "vmbr0"
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