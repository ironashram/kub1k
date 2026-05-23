variable "keycloak_url" {
  description = "Base URL of the Keycloak server"
  type        = string
  sensitive   = true
}

variable "realm_id" {
  description = "Realm to provision clients in"
  type        = string
  sensitive   = true
}

variable "internal_domain" {
  description = "Internal domain used for service ingress hostnames (grafana.<internal>, k8s.<internal>, argocd.<internal>, etc.)"
  type        = string
  sensitive   = true
}

variable "external_domain" {
  description = "External domain used for externally-reachable service hostnames (vbr.<external>, etc.)"
  type        = string
  sensitive   = true
}

variable "additional_clients" {
  description = "Extra OIDC clients to provision."
  type = list(object({
    client_id     = string
    root_url      = string
    redirect_uris = list(string)
    web_origins   = list(string)
  }))
  default = []
}

variable "wait_timeout_seconds" {
  description = "How long to wait for the realm OIDC discovery URL to return 200 before failing"
  type        = number
  default     = 1800
}

variable "wait_interval_seconds" {
  description = "Polling interval while waiting for Keycloak to become reachable"
  type        = number
  default     = 10
}
