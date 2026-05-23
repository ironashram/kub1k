resource "vault_kv_secret_v2" "client" {
  for_each = keycloak_openid_client.service

  mount = "kv"
  name  = "keycloak/clients/${each.key}"

  data_json_wo = jsonencode({
    client_id     = each.value.client_id
    client_secret = each.value.client_secret
  })

  data_json_wo_version = parseint(substr(sha256(each.value.client_secret), 0, 12), 16)
}

resource "vault_kv_secret_v2" "vaultwarden_client" {
  mount = "kv"
  name  = "keycloak/clients/${keycloak_openid_client.vaultwarden.client_id}"

  data_json_wo = jsonencode({
    client_id     = keycloak_openid_client.vaultwarden.client_id
    client_secret = keycloak_openid_client.vaultwarden.client_secret
  })

  data_json_wo_version = parseint(substr(sha256(keycloak_openid_client.vaultwarden.client_secret), 0, 12), 16)
}

resource "vault_kv_secret_v2" "additional_client" {
  count = length(var.additional_clients)

  mount = "kv"
  name  = "keycloak/clients/${keycloak_openid_client.additional[count.index].client_id}"

  data_json_wo = jsonencode({
    client_id     = keycloak_openid_client.additional[count.index].client_id
    client_secret = keycloak_openid_client.additional[count.index].client_secret
  })

  data_json_wo_version = parseint(substr(sha256(keycloak_openid_client.additional[count.index].client_secret), 0, 12), 16)
}
