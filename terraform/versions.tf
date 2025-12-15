terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    synology = {
      source  = "synology-community/synology"
      version = "0.6.4"
    }
  }
}
