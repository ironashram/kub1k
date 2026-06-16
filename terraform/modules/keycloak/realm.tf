data "vault_generic_secret" "lldap" {
  path = "kv/lldap/shared"
}

data "vault_generic_secret" "mail" {
  path = "kv/mail"
}

locals {
  base_dn = "dc=${replace(var.external_domain, ".", ",dc=")}"

  ldap_attribute_mappers = {
    "username" = {
      ldap_attribute              = "uid"
      user_model_attribute        = "username"
      is_mandatory_in_ldap        = true
      always_read_value_from_ldap = false
    }
    "first name" = {
      ldap_attribute              = "givenName"
      user_model_attribute        = "firstName"
      is_mandatory_in_ldap        = false
      always_read_value_from_ldap = true
    }
    "last name" = {
      ldap_attribute              = "sn"
      user_model_attribute        = "lastName"
      is_mandatory_in_ldap        = false
      always_read_value_from_ldap = true
    }
    "email" = {
      ldap_attribute              = "mail"
      user_model_attribute        = "email"
      is_mandatory_in_ldap        = false
      always_read_value_from_ldap = true
    }
  }
}

resource "keycloak_realm" "realm" {
  depends_on = [null_resource.wait_for_keycloak]

  realm        = var.realm_id
  enabled      = true
  display_name = var.realm_id

  ssl_required             = "external"
  registration_allowed     = false
  remember_me              = true
  login_with_email_allowed = true
  duplicate_emails_allowed = false
  reset_password_allowed   = false
  edit_username_allowed    = false

  login_theme = "m1k"

  default_signature_algorithm = "RS256"

  security_defenses {
    brute_force_detection {}
  }

  smtp_server {
    host              = data.vault_generic_secret.mail.data["hostname"]
    port              = "465"
    from              = data.vault_generic_secret.mail.data["alerts"]
    from_display_name = "Keycloak SSO"
    ssl               = true

    auth {
      username = data.vault_generic_secret.mail.data["alerts"]
      password = data.vault_generic_secret.mail.data["alerts_password"]
    }
  }
}

resource "keycloak_realm_default_client_scopes" "realm" {
  realm_id = keycloak_realm.realm.id
  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",
    "acr",
    "basic",
  ]
}

resource "keycloak_role" "admins" {
  realm_id    = keycloak_realm.realm.id
  name        = "admins"
  description = "SSO admin role, populated from lldap `admins` group via LDAP federation"
}

resource "keycloak_ldap_user_federation" "lldap" {
  realm_id = keycloak_realm.realm.id
  name     = "lldap"
  enabled  = true
  priority = 0

  edit_mode               = "READ_ONLY"
  username_ldap_attribute = "uid"
  rdn_ldap_attribute      = "uid"
  uuid_ldap_attribute     = "entryuuid"
  user_object_classes     = ["inetOrgPerson", "posixAccount"]
  connection_url          = "ldaps://ldap1.${var.external_domain}:6360 ldaps://ldap2.${var.external_domain}:6360"
  users_dn                = "ou=people,${local.base_dn}"
  bind_dn                 = "uid=admin,ou=people,${local.base_dn}"
  bind_credential         = data.vault_generic_secret.lldap.data["lldap_admin_password"]
  search_scope            = "ONE_LEVEL"

  validate_password_policy = false
  trust_email              = true
  use_truststore_spi       = "ALWAYS"
  connection_pooling       = true
  pagination               = true
  batch_size_for_sync      = 1000
  import_enabled           = true
  sync_registrations       = false
}

resource "keycloak_ldap_user_attribute_mapper" "user" {
  for_each = local.ldap_attribute_mappers

  realm_id                = keycloak_realm.realm.id
  ldap_user_federation_id = keycloak_ldap_user_federation.lldap.id
  name                    = each.key

  ldap_attribute              = each.value.ldap_attribute
  user_model_attribute        = each.value.user_model_attribute
  is_mandatory_in_ldap        = each.value.is_mandatory_in_ldap
  always_read_value_from_ldap = each.value.always_read_value_from_ldap
  read_only                   = true
  attribute_force_default     = false
}

resource "keycloak_ldap_role_mapper" "ldap_roles" {
  realm_id                = keycloak_realm.realm.id
  ldap_user_federation_id = keycloak_ldap_user_federation.lldap.id
  name                    = "ldap-roles"

  ldap_roles_dn                  = "ou=groups,${local.base_dn}"
  role_name_ldap_attribute       = "cn"
  role_object_classes            = ["groupOfUniqueNames"]
  membership_ldap_attribute      = "member"
  membership_attribute_type      = "DN"
  membership_user_ldap_attribute = "uid"
  mode                           = "READ_ONLY"
  user_roles_retrieve_strategy   = "LOAD_ROLES_BY_MEMBER_ATTRIBUTE"
  roles_ldap_filter              = "(cn=admins)"
  use_realm_roles_mapping        = true
}
