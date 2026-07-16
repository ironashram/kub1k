resource "vault_jwt_auth_backend" "oidc" {
  path               = "oidc"
  type               = "oidc"
  oidc_discovery_url = "${var.keycloak_url}/realms/${keycloak_realm.realm.id}"
  oidc_client_id     = keycloak_openid_client.service["vault"].client_id
  oidc_client_secret = keycloak_openid_client.service["vault"].client_secret
  default_role       = "default"
}

resource "vault_jwt_auth_backend_role" "default" {
  backend        = vault_jwt_auth_backend.oidc.path
  role_name      = "default"
  role_type      = "oidc"
  user_claim     = "sub"
  groups_claim   = "groups"
  oidc_scopes    = ["openid", "profile", "email"]
  bound_claims   = { groups = keycloak_role.admins.name }
  token_policies = ["default"]
  token_ttl      = 28800
  allowed_redirect_uris = [
    "https://vault.${var.external_domain}/ui/vault/auth/oidc/oidc/callback",
    "https://vault.${var.external_domain}/v1/auth/oidc/callback",
    "http://localhost:8250/oidc/callback",
  ]
}

# `admins` arrives in the `groups` claim via the realm-roles-as-groups mapper on
# the client, fed from the lldap `admins` group by the LDAP role mapper.
resource "vault_identity_group" "admins" {
  name     = keycloak_role.admins.name
  type     = "external"
  policies = ["admin"]
}

resource "vault_identity_group_alias" "admins" {
  name           = keycloak_role.admins.name
  mount_accessor = vault_jwt_auth_backend.oidc.accessor
  canonical_id   = vault_identity_group.admins.id
}
