ephemeral "vault_kv_secret_v2" "github" {
  mount = "kv"
  name  = "${var.cluster_name}/github"
}

ephemeral "vault_kv_secret_v2" "vault" {
  mount = "kv"
  name  = "${var.cluster_name}/vault"
}

ephemeral "vault_kv_secret_v2" "ssh" {
  mount = "kv"
  name  = "${var.cluster_name}/ssh"
}

ephemeral "vault_kv_secret_v2" "k3s" {
  mount = "kv"
  name  = "${var.cluster_name}/k3s"
}

ephemeral "vault_kv_secret_v2" "argocd" {
  mount = "kv"
  name  = "${var.cluster_name}/argocd"
}

ephemeral "vault_kv_secret_v2" "domain" {
  mount = "kv"
  name  = "${var.cluster_name}/domain"
}

ephemeral "vault_kv_secret_v2" "vms" {
  mount = "kv"
  name  = "${var.cluster_name}/vms"
}

data "vault_generic_secret" "vars" {
  path = "kv/${var.cluster_name}/vars"
}

