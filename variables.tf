variable "ssh_key_file" {
  default = "~/.ssh/id_m1k_2021"
}

variable "ssh_user" {
  default = "m1k"
}

variable "kube_config_output" {
  default = "~/.kube/config-files/k3s-ygg.yaml"
}

variable "kube_context" {
  default = "k3s-ygg"
}

variable "k3s_extra_args" {
  default = "--cluster-cidr=192.168.8.0/21 --flannel-backend=none --disable-network-policy --disable traefik --disable servicelb"
}

variable "masters" {
  default = [{
    name = "yggmaster01"
    ip   = "10.0.0.241"
  }]
}

variable "workers" {
  default = [{
    name = "yggworker01"
    ip   = "10.0.0.242"
    }, {
    name = "yggworker02"
    ip   = "10.0.0.243"
  }]
}
