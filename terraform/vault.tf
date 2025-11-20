ephemeral "vault_kv_secret_v2" "github" {
  mount = "kv"
  name  = "${terraform.workspace}/github"
}

ephemeral "vault_kv_secret_v2" "vault" {
  mount = "kv"
  name  = "${terraform.workspace}/vault"
}

ephemeral "vault_kv_secret_v2" "ssh" {
  mount = "kv"
  name  = "${terraform.workspace}/ssh"
}

ephemeral "vault_kv_secret_v2" "k3s" {
  mount = "kv"
  name  = "${terraform.workspace}/k3s"
}

ephemeral "vault_kv_secret_v2" "argocd" {
  mount = "kv"
  name  = "${terraform.workspace}/argocd"
}

ephemeral "vault_kv_secret_v2" "domain" {
  mount = "kv"
  name  = "${terraform.workspace}/domain"
}
