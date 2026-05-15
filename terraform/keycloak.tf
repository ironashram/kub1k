locals {
  additional_clients = [
    for host in split(",", try(data.vault_generic_secret.vars.data["oidc_extra_hostnames"], "")) :
    {
      client_id     = host
      root_url      = "https://${host}.${data.vault_generic_secret.domain.data["external"]}"
      redirect_uris = ["https://${host}.${data.vault_generic_secret.domain.data["external"]}/"]
      web_origins   = ["+"]
    }
    if host != ""
  ]
}

module "provision_keycloak" {
  count      = local.cluster_host != null ? 1 : 0
  source     = "./modules/keycloak"
  depends_on = [module.provision_apps]

  keycloak_url       = "https://keycloak.${data.vault_generic_secret.domain.data["external"]}"
  realm_id           = var.keycloak_realm_id
  internal_domain    = data.vault_generic_secret.domain.data["internal"]
  additional_clients = local.additional_clients

  providers = {
    keycloak = keycloak
    vault    = vault
  }
}
