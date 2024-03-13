
data "vault_kv_secret_v2" "github" {
  mount = "kv"
  name  = "kub1k/github"
}

data "vault_kv_secret_v2" "vault" {
  mount = "kv"
  name  = "kub1k/vault"
}

data "vault_kv_secret_v2" "ssh" {
  mount = "kv"
  name  = "kub1k/ssh"
}

data "vault_kv_secret_v2" "k3s" {
  mount = "kv"
  name  = "kub1k/k3s"
}
