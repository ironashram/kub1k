variable "keycloak_url" {
  description = "Base URL of the Keycloak server"
  type        = string
}

variable "realm_id" {
  description = "Realm to provision clients in"
  type        = string
}

variable "internal_domain" {
  description = "Internal domain used for service ingress hostnames (grafana.<internal>, k8s.<internal>, argocd.<internal>, etc.)"
  type        = string
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
