variable "k3s_extra_args" {
  default = "--cluster-cidr=172.27.0.0/21 --cluster-init --etcd-expose-metrics --kube-controller-manager-arg=bind-address=0.0.0.0 --kube-proxy-arg=metrics-bind-address=0.0.0.0 --kube-scheduler-arg=bind-address=0.0.0.0  --flannel-backend=none --disable-network-policy --disable traefik --disable servicelb"
}

variable "k3s_version" {
  default = "v1.29.1+k3s2"
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

variable "kube_context" {
  default = "kub1k"
}
