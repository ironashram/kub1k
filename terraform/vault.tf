provider "vault" {
  address = "https://vault.m1k.cloud:8200"
  token   = var.vault_token
}

data "vault_kv_secret_v2" "cloudflare_api_key" {
  mount = "kv"
  name  = "ygg/cloudflare-api-key"
}
