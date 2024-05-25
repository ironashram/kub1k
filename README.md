# kub1k
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
- Github Runners: Runner scale sets is a group of homogeneous runners that can be assigned jobs from GitHub Actions.

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

1. **Cert-Manager**

2. **External-Secrets-Operator**

3. **Lets-Encrypt-Issuers**

4. **MetalLB-CR**

5. **Kube-Prometheus-Stack**

6. **Secrets**

7. **Synology-CSI**

## Custom Helm Charts

The Helm charts included in this project are:

1. **ArgoCD-App-of-Apps**: Deploys an ArgoCD application that references other ArgoCD applications, allowing you to manage multiple applications in a centralized manner.

2. **Lets-Encrypt-Issuers**: Necessary resources for setting up Let's Encrypt issuers in cert-manager.

3. **MetalLB-CR**: Custom Resources for setting up MetalLB in your cluster.

4. **Secrets**: Secrets in your Kubernetes cluster, including the Cloudflare API key for cert-manager, ClusterSecretStore, and Synology CSI client info secret.

## License

This project is licensed under the [MIT License](LICENSE).


## Credits

The grafana dashboards are based on the followings projects:

- [Kubernetes Mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin)
- [Prometheus 2.0 Grafana dashboard](https://github.com/FUSAKLA/Prometheus2-grafana-dashboard)
- [Grafana Dashboards K8s](https://github.com/dotdc/grafana-dashboards-kubernetes)
