/*******************
  External Secrets
******************/

# Vault Credentials for External Secrets controller
resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubernetes_secret" "external_secrets" {
  depends_on = [kubernetes_namespace.external_secrets]

  metadata {
    name      = "vault-token"
    namespace = "external-secrets"
  }

  data = {
    "token" = var.vault_token
  }

  type = "Opaque"

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}
