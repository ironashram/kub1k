resource "kubernetes_labels" "worker_role" {
  for_each = {
    for node in var.worker_nodes : node.name => node
  }
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = each.value.name
  }
  labels = {
    "node-role.kubernetes.io/worker" = true
  }
}
