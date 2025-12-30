data "vault_generic_secret" "vault" {
  path = "kv/${var.cluster_name}/vault"
}

data "vault_generic_secret" "ssh" {
  path = "kv/${var.cluster_name}/ssh"
}

data "vault_generic_secret" "vms" {
  path = "kv/${var.cluster_name}/vms"
}

data "vault_generic_secret" "k3s" {
  path = "kv/${var.cluster_name}/k3s"
}

data "vault_generic_secret" "vars" {
  path = "kv/${var.cluster_name}/vars"
}

data "vault_generic_secret" "argocd" {
  path = "kv/${var.cluster_name}/argocd"
}

data "vault_generic_secret" "domain" {
  path = "kv/${var.cluster_name}/domain"

}
data "vault_generic_secret" "github" {
  path = "kv/${var.cluster_name}/github"
}
