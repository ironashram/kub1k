variable "k3s_cluster_cidr" {
  default = "172.27.0.0/21"
}

variable "k3s_service_cidr" {
  default = "172.27.8.0/21"
}

variable "k3s_cluster_dns" {
  default = "172.27.8.10"
}

variable "k3s_kube_bind_address" {
  default = "0.0.0.0"
}

variable "k3s_version" {
  default = "v1.34.2+k3s1"
}

variable "lb_pool_cidr" {
  default = "10.78.0.230/32"
}

variable "cluster_name" {
  default = "kub1k"
}

variable "remote_state_s3_endpoint" {
  description = "url for s3 backend"
}
