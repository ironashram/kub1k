terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
}
