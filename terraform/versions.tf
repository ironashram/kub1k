terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.10.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    synology = {
      source  = "ironashram/synology"
      version = "0.8.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.9.0"
    }
  }
}
