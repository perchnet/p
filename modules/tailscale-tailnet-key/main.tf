terraform {
  required_version = ">= 1.0"

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.15"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

# Create the Tailscale auth key
resource "tailscale_tailnet_key" "key" {
  reusable      = var.reusable
  ephemeral     = var.ephemeral
  preauthorized = var.preauthorized
  expiry        = var.expiry_seconds
  description   = var.description
  tags          = var.tags
}

# Optional: Create a random suffix for unique descriptions
resource "random_id" "suffix" {
  count       = var.auto_generate_suffix ? 1 : 0
  byte_length = 4
}

# Generate final description with optional suffix
locals {
  final_description = var.auto_generate_suffix ? "${var.description}-${random_id.suffix[0].hex}" : var.description
}

# Update the key with the final description if suffix is used
resource "tailscale_tailnet_key" "key_with_suffix" {
  count = var.auto_generate_suffix ? 1 : 0

  reusable      = var.reusable
  ephemeral     = var.ephemeral
  preauthorized = var.preauthorized
  expiry        = var.expiry_seconds
  description   = local.final_description
  tags          = var.tags
}

# Locals for outputs
locals {
  key_resource = var.auto_generate_suffix ? tailscale_tailnet_key.key_with_suffix[0] : tailscale_tailnet_key.key
}
