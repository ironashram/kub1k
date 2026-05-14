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
