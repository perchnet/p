# resource "oci_objectstorage_bucket" "tf_state_bucket" {
#   compartment_id = module.authenticate_oci.compartment_ocid
#   name           = "terraform-state"
#   namespace      = data.oci_objectstorage_namespace.ns.namespace
# 
#   storage_tier = "Standard"
#   access_type  = "NoPublicAccess"
#   versioning   = "Enabled"
# }
# 

#module "authenticate_oci" {
#  source   = "./modules/authenticate-oci"
#  op_vault = local.perchnet_vault
#}
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
  source          = "./modules/get-pubkey-md5"
  private_key_pem = local.private_key_pem
}
provider "oci" {
  tenancy_ocid = local.tenancy_ocid
  user_ocid    = local.user_ocid
  fingerprint  = module.get_pubkey_md5.pubkey_md5
  private_key  = local.private_key_pem
  region       = local.region
}
data "oci_objectstorage_namespace" "ns" {
  compartment_id = local.compartment_ocid
}