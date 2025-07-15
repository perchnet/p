terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.9.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "2.1.2"
    }
  }
}
variable "op_vault" {
  type    = string
  default = "perchnet"
}

data "onepassword_item" "oci_terraform" {
  vault = var.op_vault
  #title = "oci-terraform-as-ssh"
  title = "oci"
}

# data "tls_public_key" "api_key" {
#   private_key_pem = local.private_key_pem
# }
#data "tls_certificate" "api_public_key" {
#  content = data.onepassword_item.oci_terraform.public_key
#}
locals {
  private_key_pem = data.onepassword_item.oci_terraform.private_key
  #public_key_fingerprint_md5 = data.tls_public_key.api_key.public_key_fingerprint_md5

  tenancy_ocid = one(
    [for section in data.onepassword_item.oci_terraform.section :
      one([for field in section.field : field.value if field.label == "tenancy-ocid"])
    ]
  )

  user_ocid = one(
    [for section in data.onepassword_item.oci_terraform.section :
      one([for field in section.field : field.value if field.label == "user-ocid"])
    ]
  )

  compartment_ocid = one(
    [for section in data.onepassword_item.oci_terraform.section :
      one([for field in section.field : field.value if field.label == "compartment-ocid"])
    ]
  )

  region = one(
    [for section in data.onepassword_item.oci_terraform.section :
      one([for field in section.field : field.value if field.label == "region"])
    ]
  )
}
module "get_pubkey_md5" {
  source          = "../get-pubkey-md5"
  private_key_pem = local.private_key_pem
}
provider "oci" {
  tenancy_ocid = local.tenancy_ocid
  user_ocid    = local.user_ocid
  fingerprint  = module.get_pubkey_md5.pubkey_md5
  private_key  = local.private_key_pem
  region       = local.region
}

output "compartment_ocid" {
  value = local.compartment_ocid
}
output "tenancy_ocid" {
  value = local.tenancy_ocid
}
output "user_ocid" {
  value = local.user_ocid
}
output "region" {
  value = local.region
}
output "private_key_pem" {
  value     = local.private_key_pem
  sensitive = true
}
output "fingerprint" {
  value = module.get_pubkey_md5.pubkey_md5
}