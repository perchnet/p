# modules/tailscale-vm/variables.tf
variable "tailscale_auth_key" {
  description = "value of the tailscale auth key"
  type        = string
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

# TODO: implement this with drop-ins
# variable "extra_tailscaled_args" {
#   description = "List of extra arguments to pass to tailscaled"
#   type        = list(string)
#   default     = []
# }
#
variable "tailscale_extra_args" {
  description = "List of extra arguments to pass to tailscale up"
  type        = list(string)
  default     = []
}

variable "late_commands" {
  description = "List of commands to run after tailscale up"
  type        = list(string)
  default     = []
}
