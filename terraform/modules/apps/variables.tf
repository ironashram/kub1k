variable "vault_token" {
  sensitive = true
  ephemeral = true
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

variable "worker_names" {
  sensitive = false
}

variable "lb_pool_cidr" {
  sensitive = false
}

variable "vault_secret_revision" {
  default = "2"
}

variable "cluster_name" {
  sensitive = false
}
