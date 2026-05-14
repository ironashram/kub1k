output "client_ids" {
  description = "Map of service-name -> Keycloak internal client id (UUID)"
  value       = { for k, v in keycloak_openid_client.service : k => v.id }
}

output "vault_paths" {
  description = "Map of service-name -> Vault KV path where the client_secret is stored"
  value       = { for k, v in vault_kv_secret_v2.client : k => "kv/${v.name}" }
}
