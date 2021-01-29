variable "vault_ca" {
  description = "vault CA file"
  default     = "certs/vault_ca_cert.pem"
}
variable "vault_crt" {
  description = "vault self signed cert file"
  default     = "certs/vault_cert.pem"
}
variable "vault_key" {
  description = "vault self sign key file"
  default     = "certs/vault_private_key.pem"
}
variable "gcp_creds" {
  description = "gcp kms service account key file"
  default     = "credentials.json"
}
variable "cluster_size" {
  description = "vault cluster size"
  default     = 3
}

variable "aquasec_download_user" {
  description = "username of aquasec downloads"
  default     = ""
}


variable "aquasec_download_pass" {
  description = "pwd of aquasec downloads"
  default     = ""
}