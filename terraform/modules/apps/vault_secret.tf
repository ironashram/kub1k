resource "kubernetes_namespace" "external_secrets" {
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

resource "null_resource" "clean_external_secrets_finalizer" {
  depends_on = [kubernetes_namespace.external_secrets]

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      kubectl get namespace "external-secrets" -o json \
        | jq '.metadata.finalizers = []' \
        | kubectl replace --raw /api/v1/namespaces/external-secrets/finalize -f -
    EOT
  }

  triggers = {
    external_secrets_ns = kubernetes_namespace.external_secrets.id
  }
}
