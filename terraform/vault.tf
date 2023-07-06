provider "vault" {
  address = "https://vault.m1k.cloud:8200"
  token   = var.vault_token
}

data "vault_kv_secret_v2" "github_token" {
  mount = "kv"
  name  = "ygg/github_token"
}
