# Kub1k
The name comes from a silly portmanteau between kube and m1k (my nickname)

This repository contains the Terraform code for deploying and managing a homelab k8s infrastructure.

## Overview

The Kub1k project aims to provide a scalable and reliable Kubernetes cluster using the K3s lightweight Kubernetes distribution. The infrastructure is provisioned using Terraform and includes the following components:

- ArgoCD: A GitOps continuous delivery tool for Kubernetes.
- Calico: A networking and network security solution for Kubernetes.
- External Secrets: A controller for managing secrets stored in external secret management systems.
- MetalLB: A load balancer implementation for bare metal Kubernetes clusters.
- Nginx Ingress Controller: An Ingress controller for Kubernetes using Nginx.
- Vault: A secrets management tool for securely storing and accessing sensitive information.
- SSH Configuration: Configuration for SSH access to the Kubernetes cluster.

## Prerequisites

Before deploying the infrastructure, make sure you have the following prerequisites:

- Terraform: Version >= 1.0.0
- Helm: Version >= 3.0.0
- Kubernetes: Version >= 1.21.0
- Vault: Version >= 1.7.0

## Getting Started

To deploy the infrastructure, follow these steps:

1. Clone this repository to your local machine.
2. Navigate to the project directory.
3. Initialize the Terraform backend by running `make init kub1k`.
4. Review and modify the variables in the `variables.tf` file according to your environment.
5. Run `make plan kub1k` to see the execution plan.
6. Run `make apply kub1k` to deploy the infrastructure.

For more detailed instructions, please refer to the [Terraform documentation](https://www.terraform.io/docs/index.html).


## ArgoCD Applications

The ArgoCD applications included in this project are:

1. **Cert-Manager**: A native Kubernetes certificate management controller. It can help with issuing certificates from a variety of sources, such as Let’s Encrypt, HashiCorp Vault, Venafi, a simple signing key pair, or self-signed.

2. **External-Secrets-Operator**: Kubernetes External Secrets allows you to use external secret management systems, like AWS Secrets Manager or Vault, with Kubernetes. Secrets are written with a controller into Kubernetes secrets. Then they can be used via a reference in the pod spec.

3. **Lets-Encrypt-Issuers**: This application sets up ClusterIssuer resources for cert-manager for issuing Let's Encrypt certificates.

4. **MetalLB-CR**: MetalLB is a load balancer implementation for bare metal Kubernetes clusters, using standard routing protocols. This application sets up the Custom Resources required for MetalLB.

5. **Prometheus-Operator**: The Prometheus Operator provides easy monitoring definitions for Kubernetes services and deployment and management of Prometheus instances.

6. **Secrets**: This application manages the deployment of Kubernetes secrets.

7. **Synology-CSI**: Synology Container Storage Interface (CSI) is a driver that exposes Synology storage appliances to container orchestrators for persistent storage.

## Custom Helm Charts

The Helm charts included in this project are:

1. **ArgoCD-App-of-Apps**: This chart deploys an ArgoCD application that references other ArgoCD applications, allowing you to manage multiple applications in a centralized manner.

2. **Lets-Encrypt-Issuers**: This chart deploys the necessary resources for setting up Let's Encrypt issuers in cert-manager.

3. **MetalLB-CR**: This chart deploys the necessary Custom Resources for setting up MetalLB in your cluster.

4. **Secrets**: This chart manages the deployment of various secrets in your Kubernetes cluster, including the Cloudflare API key for cert-manager, ClusterSecretStore, and Synology CSI client info secret.

## License

This project is licensed under the [MIT License](LICENSE).
