<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.0)

- <a name="requirement_ct"></a> [ct](#requirement\_ct) (0.13.0)

- <a name="requirement_github"></a> [github](#requirement\_github) (~> 6.0)

- <a name="requirement_http"></a> [http](#requirement\_http) (>= 3.5.0)

- <a name="requirement_onepassword"></a> [onepassword](#requirement\_onepassword) (2.1.2)

- <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) (>= 0.82.1)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.7.2)

- <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) (>= 0.21.1)

- <a name="requirement_time"></a> [time](#requirement\_time) (>= 0.13.1)

## Providers

The following providers are used by this module:

- <a name="provider_github"></a> [github](#provider\_github) (6.6.0)

- <a name="provider_onepassword"></a> [onepassword](#provider\_onepassword) (2.1.2)

- <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) (0.21.1)

- <a name="provider_terraform"></a> [terraform](#provider\_terraform)

## Modules

The following Modules are called:

### <a name="module_block_storage"></a> [block\_storage](#module\_block\_storage)

Source: ./modules/block-storage

Version:

### <a name="module_coreos_metadata"></a> [coreos\_metadata](#module\_coreos\_metadata)

Source: github.com/perchnet/terraform-module-coreos-metadata

Version: c700d78

### <a name="module_debian13"></a> [debian13](#module\_debian13)

Source: github.com/b-/terraform-bpg-proxmox//modules/vm

Version: 8d9dd51

### <a name="module_n8n_block_storage"></a> [n8n\_block\_storage](#module\_n8n\_block\_storage)

Source: ./modules/block-storage

Version:

### <a name="module_n8n_vm"></a> [n8n\_vm](#module\_n8n\_vm)

Source: github.com/b-/terraform-bpg-proxmox//modules/vm

Version: 8d9dd51

### <a name="module_pkcs8_to_pem"></a> [pkcs8\_to\_pem](#module\_pkcs8\_to\_pem)

Source: ./modules/ssh-key-converter

Version:

### <a name="module_proxmox_images"></a> [proxmox\_images](#module\_proxmox\_images)

Source: ./modules/proxmox-image

Version:

### <a name="module_ubuntu22"></a> [ubuntu22](#module\_ubuntu22)

Source: github.com/b-/terraform-bpg-proxmox//modules/vm

Version: 8d9dd51

### <a name="module_vm_minimal_config"></a> [vm\_minimal\_config](#module\_vm\_minimal\_config)

Source: github.com/b-/terraform-bpg-proxmox//modules/vm

Version: 8d9dd51

## Resources

The following resources are used by this module:

- [github_repository.p_repository](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) (resource)
- [github_repository_ruleset.p_merge_queue](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) (resource)
- [tailscale_tailnet_key.tailscale_key](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/tailnet_key) (resource)
- [terraform_data.n8n_tskey_stable](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) (resource)
- [terraform_data.n8n_tskey_stable_replacement_hook](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) (resource)
- [terraform_data.tailscale_auth_key_stable](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) (resource)
- [terraform_data.tskey_replacement_hook](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) (resource)
- [onepassword_item.github_infra_app](https://registry.terraform.io/providers/1Password/onepassword/2.1.2/docs/data-sources/item) (data source)
- [onepassword_item.proxmox_api](https://registry.terraform.io/providers/1Password/onepassword/2.1.2/docs/data-sources/item) (data source)
- [onepassword_item.proxmox_ssh](https://registry.terraform.io/providers/1Password/onepassword/2.1.2/docs/data-sources/item) (data source)
- [onepassword_item.tailscale_apikey](https://registry.terraform.io/providers/1Password/onepassword/2.1.2/docs/data-sources/item) (data source)
- [onepassword_vault.perchnet_vault](https://registry.terraform.io/providers/1Password/onepassword/2.1.2/docs/data-sources/vault) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_onepassword_sdk_token"></a> [onepassword\_sdk\_token](#input\_onepassword\_sdk\_token)

Description: n/a

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### <a name="output_images"></a> [images](#output\_images)

Description: n/a
<!-- END_TF_DOCS -->
