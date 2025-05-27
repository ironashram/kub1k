terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.0.0"
    }
  }
}
