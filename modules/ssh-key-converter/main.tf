terraform {
  required_version = ">= 1.0"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}
variable "pkcs8_key_content" {
  description = "Plaintext content of a PKCS8-encoded SSH key"
  type        = string
  sensitive   = true
}

data "external" "pkcs8_to_pem" {
  program = ["${path.module}/convert_key.sh"]

  query = {
    pkcs8_key = var.pkcs8_key_content
  }
}

output "pem_key_content" {
  description = "Plaintext content of the PEM-encoded SSH key"
  value       = data.external.pkcs8_to_pem.result.pem_key
  sensitive   = true
}
