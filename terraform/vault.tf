
data "vault_kv_secret_v2" "github" {
  mount = "kv"
  name  = "${terraform.workspace}/github"
}

data "vault_kv_secret_v2" "vault" {
  mount = "kv"
  name  = "${terraform.workspace}/vault"
}

data "vault_kv_secret_v2" "ssh" {
  mount = "kv"
  name  = "${terraform.workspace}/ssh"
}

data "vault_kv_secret_v2" "k3s" {
  mount = "kv"
  name  = "${terraform.workspace}/k3s"
}

data "vault_kv_secret_v2" "argocd" {
  mount = "kv"
  name  = "${terraform.workspace}/argocd"
}

data "vault_kv_secret_v2" "synology" {
  mount = "kv"
  name  = "${terraform.workspace}/synology"
}
