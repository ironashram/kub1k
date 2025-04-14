variable "k3s_extra_args" {
  default = ["--cluster-cidr=172.27.0.0/21", "--service-cidr=172.27.8.0/21", "--cluster-dns=172.27.8.10", "--cluster-init", "--etcd-expose-metrics", "--kube-controller-manager-arg=bind-address=0.0.0.0", "--kube-proxy-arg=metrics-bind-address=0.0.0.0", "--kube-scheduler-arg=bind-address=0.0.0.0", "--flannel-backend=none", "--disable-network-policy", "--disable traefik", "--disable servicelb", "--disable coredns"]
}

variable "k3s_cluster_dns" {
  default = "172.27.8.10"
}

variable "k3s_version" {
  default = "v1.32.3+k3s1"
}

variable "control" {
  default = [{
    name = "kub1k-control-01"
    ip   = "10.0.0.241"
  }]
}

variable "worker" {
  default = [{
    name = "kub1k-worker-01"
    ip   = "10.0.0.242"
    }, {
    name = "kub1k-worker-02"
    ip   = "10.0.0.243"
  }]
}

variable "remote_state_s3_endpoint" {
  description = "url for s3 backend"
}
