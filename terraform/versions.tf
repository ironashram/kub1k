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
      version = "5.8.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    synology = {
      source  = "ironashram/synology"
      version = "0.7.0-ironashram"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
    }
  }
}
