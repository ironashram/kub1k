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
  host     = ephemeral.vault_kv_secret_v2.vms.data.synology_host
  user     = ephemeral.vault_kv_secret_v2.vms.data.synology_user
  password = ephemeral.vault_kv_secret_v2.vms.data.synology_password
}
