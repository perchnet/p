variable "private_key_pem" {
  type      = string
  sensitive = true
}

data "external" "pubkey_md5" {
  program = ["bash", "${path.module}/get_pubkey_md5.sh"]

  query = {
    private_key = var.private_key_pem
  }
}

output "pubkey_md5" {
  value = data.external.pubkey_md5.result.pubkey_md5
}
