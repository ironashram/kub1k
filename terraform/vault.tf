provider "vault" {
  address = "https://vault.m1k.cloud:8200"
  token   = var.vault_token
}

data "vault_kv_secret_v2" "git_token" {
  mount = "kv"
  name  = "ygg/github_token"
}

data "vault_kv_secret_v2" "git_user" {
  mount = "kv"
  name  = "ygg/github_user"
}
