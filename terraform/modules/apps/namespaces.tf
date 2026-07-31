resource "kubernetes_namespace_v1" "external_secrets" {
  metadata {
    name = "external-secrets"
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }

  timeouts {
    delete = "30s"
  }
}
