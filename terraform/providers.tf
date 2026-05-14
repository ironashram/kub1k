provider "vault" {}

provider "helm" {
  kubernetes = {
    host                   = local.cluster_host
    cluster_ca_certificate = local.cluster_ca_certificate
    client_certificate     = local.client_certificate
    client_key             = local.client_key
  }
}

provider "kubernetes" {
  host                   = local.cluster_host
  cluster_ca_certificate = local.cluster_ca_certificate
  client_certificate     = local.client_certificate
  client_key             = local.client_key
}

provider "kubectl" {
  host                   = local.cluster_host
  cluster_ca_certificate = local.cluster_ca_certificate
  client_certificate     = local.client_certificate
  client_key             = local.client_key
  load_config_file       = false
}

provider "synology" {
  host     = data.vault_generic_secret.vms.data["synology_host"]
  user     = data.vault_generic_secret.vms.data["synology_user"]
  password = data.vault_generic_secret.vms.data["synology_password"]
}

provider "keycloak" {
  client_id     = "admin-cli"
  username      = data.vault_generic_secret.keycloak.data["bootstrap_admin_user"]
  password      = data.vault_generic_secret.keycloak.data["bootstrap_admin_password"]
  url           = "https://keycloak.${data.vault_generic_secret.domain.data["external"]}"
  realm         = "master"
  initial_login = false
}
