resource "kubernetes_labels" "worker_role" {
  for_each    = null_resource.k3s_worker
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = each.key
  }
  labels = {
    "node-role.kubernetes.io/worker" = true
  }
}
