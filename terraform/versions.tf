terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.4.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.13.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    synology = {
      source  = "ironashram/synology"
      version = "0.9.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.10.0"
    }
  }
}
