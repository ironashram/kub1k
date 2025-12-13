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

resource "kubernetes_secret_v1" "external_secrets" {
  depends_on = [kubernetes_namespace_v1.external_secrets]

  metadata {
    name      = "vault-token"
    namespace = "external-secrets"
  }

  data_wo = {
    "token" = var.vault_token
  }

  data_wo_revision = var.vault_secret_revision

  type = "Opaque"

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}
