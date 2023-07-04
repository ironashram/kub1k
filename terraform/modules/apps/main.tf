/*************************
  Provider Configuration
*************************/
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
