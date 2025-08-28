terraform {
}

data "onepassword_item" "tailscale_apikey" {
  vault = local.perchnet_vault
  uuid  = "cvh7gepgwlnb7yxtkxsvlsokti"
}

provider "tailscale" {
  oauth_client_id     = data.onepassword_item.tailscale_apikey.username
  oauth_client_secret = data.onepassword_item.tailscale_apikey.credential
  scopes              = ["all"]
}

locals {
}
