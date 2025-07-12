# Tailscale Key Terraform Module

This module creates and manages Tailscale auth keys with flexible configuration options.

## Features

- Create reusable or single-use auth keys
- Configure ephemeral or persistent nodes
- Set custom expiry times (up to 90 days)
- Apply tags to devices using the key
- Optional auto-generated unique suffixes
- Comprehensive validation and outputs

## Usage

### Basic Usage

```hcl
module "tailscale_key" {
  source = "./modules/tailscale-key"
  
  description = "Key for production servers"
  tags        = ["tag:server", "tag:production"]
}
```

### Ephemeral Key for Testing

```hcl
module "test_key" {
  source = "./modules/tailscale-key"
  
  description   = "Ephemeral key for testing"
  ephemeral     = true
  reusable      = false
  expiry_days   = 1
  tags          = ["test", "ephemeral"]
}
```

### Persistent Server Key

```hcl
module "server_key" {
  source = "./modules/tailscale-key"
  
  description           = "Persistent server key"
  ephemeral            = false
  reusable             = true
  expiry_days          = 90
  auto_generate_suffix = true
  tags                 = ["server", "persistent"]
}
```

### Using with VM Module

```hcl
module "vm_auth_key" {
  source = "./modules/tailscale-key"
  
  description = "Auth key for VM ${var.vm_name}"
  tags        = var.tailscale_tags
}

module "tailscale_vm" {
  source = "./modules/tailscale-vm"
  
  tailscale_auth_key = module.vm_auth_key.key
  vm_name           = var.vm_name
  # ... other vm configuration
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `description` | Description for the Tailscale auth key | `string` | n/a | yes |
| `reusable` | Whether the auth key can be used multiple times | `bool` | `true` | no |
| `ephemeral` | Whether nodes using this key are ephemeral | `bool` | `false` | no |
| `preauthorized` | Whether nodes using this key are automatically authorized | `bool` | `true` | no |
| `expiry_seconds` | Number of seconds until the key expires (max 90 days) | `number` | `7776000` | no |
| `expiry_days` | Alternative way to specify expiry in days | `number` | `null` | no |
| `tags` | List of tags to apply to devices using this key | `list(string)` | `[]` | no |
| `auto_generate_suffix` | Whether to append a random suffix to the description | `bool` | `false` | no |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| `key` | The generated Tailscale auth key | Yes |
| `key_id` | The ID of the Tailscale auth key | No |
| `description` | The final description of the auth key | No |
| `expiry` | The expiry time of the auth key | No |
| `created_at` | When the auth key was created | No |
| `capabilities` | The capabilities of the auth key | No |
| `tags` | The tags associated with the auth key | No |
| `is_valid` | Whether the key exists and is valid | No |
| `key_resource` | The complete Tailscale key resource | Yes |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| tailscale | ~> 0.15 |

## Providers

| Name | Version |
|------|---------|
| tailscale | ~> 0.15 |
| random | n/a |

## Key Types

### Ephemeral vs Persistent

- **Ephemeral** (`ephemeral = true`): Nodes are automatically removed when they go offline
- **Persistent** (`ephemeral = false`): Nodes remain in the tailnet even when offline

### Reusable vs Single-use

- **Reusable** (`reusable = true`): Key can be used by multiple devices
- **Single-use** (`reusable = false`): Key becomes invalid after first use

### Common Patterns

1. **Development/Testing**: Ephemeral, single-use, short expiry
2. **Production Servers**: Persistent, reusable, long expiry
3. **CI/CD**: Ephemeral, reusable, medium expiry
4. **Personal Devices**: Persistent, single-use, long expiry

## Security Considerations

- Auth keys are marked as sensitive in Terraform state
- Keys are validated after creation
- Short expiry times reduce security risk
- Tags help with device management and ACLs
- Use single-use keys when possible for better security

## Examples

See the `examples/` directory for complete usage examples:
- `examples/basic/` - Basic key creation
- `examples/ephemeral/` - Ephemeral keys for testing
- `examples/with-vm/` - Integration with VM modules