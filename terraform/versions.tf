terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.21.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">=3.22.0"
    }
  }
}
