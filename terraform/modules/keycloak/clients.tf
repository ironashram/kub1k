locals {
  clients = {
    grafana = {
      name          = "Grafana"
      root_url      = "https://grafana.${var.internal_domain}"
      redirect_uris = ["https://grafana.${var.internal_domain}/login/generic_oauth"]
      web_origins   = ["+"]
    }
    argocd = {
      name = "ArgoCD"
      root_url = "https://argocd.${var.internal_domain}"
      redirect_uris = [
        "https://argocd.${var.internal_domain}/auth/callback",
        "http://localhost:8085/auth/callback",
      ]
      web_origins = ["+"]
    }
    headlamp = {
      name          = "Headlamp"
      root_url      = "https://k8s.${var.internal_domain}"
      redirect_uris = ["https://k8s.${var.internal_domain}/oidc-callback"]
      web_origins   = ["+"]
    }
    oauth2-proxy = {
      name          = "oauth2-proxy"
      root_url      = "https://oauth2-proxy.${var.internal_domain}"
      redirect_uris = ["https://oauth2-proxy.${var.internal_domain}/oauth2/callback"]
      web_origins   = ["+"]
    }
  }
}

resource "keycloak_openid_client" "this" {
  depends_on = [null_resource.wait_for_keycloak]
  for_each   = local.clients

  realm_id  = var.realm_id
  client_id = each.key
  name      = each.value.name

  enabled                      = true
  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  direct_access_grants_enabled = false

  root_url      = each.value.root_url
  base_url      = "/"
  valid_redirect_uris  = each.value.redirect_uris
  web_origins          = each.value.web_origins
  admin_url            = each.value.root_url
}

resource "keycloak_openid_client_default_scopes" "this" {
  for_each   = keycloak_openid_client.this
  realm_id   = var.realm_id
  client_id  = each.value.id
  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",
    "acr",
    "basic",
  ]
}
