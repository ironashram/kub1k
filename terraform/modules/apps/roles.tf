resource "kubernetes_labels" "worker_role" {
  count       = length(var.worker_names)
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = var.worker_names[count.index]
  }
  labels = {
    "node-role.kubernetes.io/worker" = true
  }
}
