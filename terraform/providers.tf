/*************************
  Provider Configuration
*************************/

provider "vault" {}

provider "helm" {
  kubernetes {
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

provider "synology" {
  url      = data.vault_kv_secret_v2.synology.data.url
  username = data.vault_kv_secret_v2.synology.data.username
  password = data.vault_kv_secret_v2.synology.data.password
}
