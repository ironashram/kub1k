variable "vault_token" {
  sensitive = true
}

variable "git_token" {
  sensitive = true
}

variable "git_user" {
  sensitive = true
}

variable "git_repo" {
  sensitive = true
}

variable "git_repo_name" {
  sensitive = true
}

variable "argocd_admin_password" {
  sensitive = true
}

variable "k3s_cluster_dns" {}

variable "internal_domain" {}

variable "external_domain" {}
