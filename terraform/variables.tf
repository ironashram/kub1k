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
  default = "v1.33.0+k3s1"
}

variable "control_nodes" {
  default = [{
    name = "control-01"
    ip = "10.0.0.241"
  }]
}

variable "worker_nodes" {
  default = [{
    name = "worker-01"
    ip = "10.0.0.242"
  },{
    name = "worker-02"
    ip = "10.0.0.243"
  }]
}

variable "remote_state_s3_endpoint" {
  description = "url for s3 backend"
}
