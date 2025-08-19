variable "node" {
  type        = string
  description = "proxmox ve cluster node"
}
variable "storage" {
  type        = string
  description = "datastore to use"
}
variable "size" {
  description = "block storage size in gb"
  type        = number
  default     = 1
}

variable "name" {
  type    = string
  default = "Data-vm"
}
variable "description" {
  default = null
  type    = string
}
variable "tags" {
  type    = list(string)
  default = ["terraform", "block-storage"]
}
