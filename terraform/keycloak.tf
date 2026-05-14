module "provision_keycloak" {
  count      = local.cluster_host != null ? 1 : 0
  source     = "./modules/keycloak"
  depends_on = [module.provision_apps]

  keycloak_url    = "https://keycloak.${data.vault_generic_secret.domain.data["external"]}"
  realm_id        = "m1k"
  internal_domain = data.vault_generic_secret.domain.data["internal"]

  providers = {
    keycloak = keycloak
    vault    = vault
  }
}
