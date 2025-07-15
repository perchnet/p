terraform {
  required_version = ">= 1.0"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "perchnet"

    workspaces {
      name = "proxmox"
    }

  }
  # backend "oci" {
  #   bucket = "terraform-state"
  #   region = "us-ashburn-1"
  #   namespace = "idlv6vmnu8ya"
  # }
}

resource "oci_objectstorage_bucket" "tf_state_bucket" {
  #Required
  compartment_id = "ocid1.compartment.oc1..aaaaaaaa4waadiumj5cxjrq6logxjyvllj4i56gxkkhmnsiwkwqc64tnidoa"
  name           = "terraform-state"
  namespace      = data.oci_objectstorage_namespace.ns.namespace

  #Optional
  access_type = "NoPublicAccess"
  #auto_tiering = var.bucket_auto_tiering
  #defined_tags = {"Operations.CostCenter"= "42"}
  #freeform_tags = {"Department"= "Finance"}
  #kms_key_id = oci_kms_key.test_key.id
  #metadata = var.bucket_metadata
  #object_events_enabled = var.bucket_object_events_enabled
  #storage_tier = var.bucket_storage_tier
  #retention_rules {
  #    display_name = var.retention_rule_display_name
  #    duration {
  #        #Required
  #        time_amount = var.retention_rule_duration_time_amount
  #        time_unit = var.retention_rule_duration_time_unit
  #    }
  #    time_rule_locked = var.retention_rule_time_rule_locked
  #}
  versioning = "Enabled"
}