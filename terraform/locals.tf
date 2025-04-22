locals {
  kube_config_output = pathexpand("~/.kube/config-files/${terraform.workspace}.yaml")

  // decode base64 kubeconfig from vault
  kubeconfig             = try(yamldecode(base64decode(data.vault_kv_secret_v2.k3s.data.kubeconfig)), null)
  cluster_host           = try(local.kubeconfig.clusters[0].cluster.server, null)
  cluster_ca_certificate = try(base64decode(local.kubeconfig.clusters[0].cluster.certificate-authority-data), null)
  client_certificate     = try(base64decode(local.kubeconfig.users[0].user.client-certificate-data), null)
  client_key             = try(base64decode(local.kubeconfig.users[0].user.client-key-data), null)



  control_nodes = [
    for i in var.control_nodes : {
      name = "${terraform.workspace}-${i.name}"
      ip   = i.ip
    }
  ]

  worker_nodes = [
    for i in var.worker_nodes : {
      name = "${terraform.workspace}-${i.name}"
      ip   = i.ip
    }
  ]

  k3s_extra_args = join(" ", [
    "--cluster-cidr=${var.k3s_cluster_cidr}",
    "--service-cidr=${var.k3s_service_cidr}",
    "--cluster-dns=${var.k3s_cluster_dns}",
    "--cluster-init",
    "--etcd-expose-metrics",
    "--kube-controller-manager-arg=bind-address=${var.k3s_kube_bind_address}",
    "--kube-proxy-arg=metrics-bind-address=${var.k3s_kube_bind_address}",
    "--kube-scheduler-arg=bind-address=${var.k3s_kube_bind_address}",
    "--flannel-backend=none",
    "--disable-kube-proxy",
    "--disable-network-policy",
    "--disable=traefik",
    "--disable=servicelb",
    "--disable=coredns"
  ])
}
