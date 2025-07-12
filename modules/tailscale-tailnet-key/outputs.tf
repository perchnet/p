# modules/tailscale-tailnet-key/outputs.tf

output "key" {
  description = "The generated Tailscale auth key"
  value       = local.key_resource.key
  sensitive   = true
}

output "key_id" {
  description = "The ID of the Tailscale auth key"
  value       = local.key_resource.id
}

output "description" {
  description = "The final description of the auth key"
  value       = local.key_resource.description
}

output "expiry" {
  description = "The expiry time of the auth key"
  value       = local.key_resource.expiry
}

output "created_at" {
  description = "When the auth key was created"
  value       = local.key_resource.created_at
}

output "capabilities" {
  description = "The capabilities of the auth key"
  value = {
    reusable      = local.key_resource.reusable
    ephemeral     = local.key_resource.ephemeral
    preauthorized = local.key_resource.preauthorized
  }
}

output "tags" {
  description = "The tags associated with the auth key"
  value       = local.key_resource.tags
}


output "key_resource" {
  description = "The complete Tailscale key resource (for advanced use cases)"
  value       = local.key_resource
  sensitive   = true
}
