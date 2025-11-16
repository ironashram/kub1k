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

variable "k3s_cluster_dns" {
  sensitive = true
}

variable "internal_domain" {
  sensitive = true
}

variable "external_domain" {
  sensitive = true
}

variable "k8s_endpoint" {
  sensitive = true
}

variable "worker_nodes" {
  sensitive = false
}

variable "lb_pool_cidr" {
  sensitive = false
}
