locals {
  kube_config_output = pathexpand("~/.kube/config-files/${var.cluster_name}.yaml")

  // decode base64 kubeconfig from vault
  kubeconfig             = try(yamldecode(base64decode(ephemeral.vault_kv_secret_v2.k3s.data.kubeconfig)), null)
  cluster_host           = try(local.kubeconfig.clusters[0].cluster.server, null)
  cluster_ca_certificate = try(base64decode(local.kubeconfig.clusters[0].cluster.certificate-authority-data), null)
  client_certificate     = try(base64decode(local.kubeconfig.users[0].user.client-certificate-data), null)
  client_key             = try(base64decode(local.kubeconfig.users[0].user.client-key-data), null)

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

  control_mgmt_macs = [for i in range(var.control_count) : format("02:00:00:a1:00:%02x", i + 1)]
  control_mgmt_ips  = [for i in range(var.control_count) : "${var.mgmt_ip_base}.${i + 11}"]
  control_names     = [for i in range(var.control_count) : "${var.cluster_name}-control-${i + 1}"]
  worker_mgmt_macs  = [for i in range(var.worker_count) : format("02:00:00:a1:11:%02x", i + 1)]
  worker_mgmt_ips   = [for i in range(var.worker_count) : "${var.mgmt_ip_base}.${i + 21}"]
  worker_names      = [for i in range(var.worker_count) : "${var.cluster_name}-worker-${i + 1}"]
  domain_name       = data.vault_generic_secret.vars.data["domain_name"]
  ssh_public_key    = data.vault_generic_secret.vars.data["ssh_public_key"]
}
