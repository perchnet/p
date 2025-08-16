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
