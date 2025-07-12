# modules/tailscale-tailnet-key/variables.tf

variable "description" {
  description = "Description for the Tailscale auth key"
  type        = string

  validation {
    condition     = length(var.description) > 0
    error_message = "Description cannot be empty."
  }
}

variable "reusable" {
  description = "Whether the auth key can be used multiple times"
  type        = bool
  default     = true
}

variable "ephemeral" {
  description = "Whether nodes using this key are ephemeral (removed when they go offline)"
  type        = bool
  default     = false
}

variable "preauthorized" {
  description = "Whether nodes using this key are automatically authorized"
  type        = bool
  default     = true
}

variable "expiry_seconds" {
  description = "Number of seconds until the key expires (max 90 days = 7776000 seconds)"
  type        = number
  default     = 7776000 # 90 days

  validation {
    condition     = var.expiry_seconds > 0 && var.expiry_seconds <= 7776000
    error_message = "Expiry must be between 1 and 7776000 seconds (90 days)."
  }
}

variable "tags" {
  description = "List of tags to apply to devices using this key"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for tag in var.tags : can(regex("^tag:[a-zA-Z][a-zA-Z0-9_-]*$", tag))
    ])
    error_message = "Tags must start with tag: and contain only letters, numbers, underscores, and hyphens."
  }
}

variable "auto_generate_suffix" {
  description = "Whether to automatically append a random suffix to the description for uniqueness"
  type        = bool
  default     = false
}
