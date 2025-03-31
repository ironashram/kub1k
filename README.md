[![Terraform Plan](https://github.com/ironashram/kub1k/actions/workflows/terraform-plan.yaml/badge.svg)](https://github.com/ironashram/kub1k/actions/workflows/terraform-plan.yaml)
[![Terraform Apply](https://github.com/ironashram/kub1k/actions/workflows/terraform-apply.yaml/badge.svg)](https://github.com/ironashram/kub1k/actions/workflows/terraform-apply.yaml)

# kub1k
The name comes from a silly portmanteau between kube and m1k (my nickname)

This repository contains the Terraform code for deploying and managing a homelab k8s infrastructure.

## Overview

The Kub1k project aims to provide a scalable and reliable Kubernetes cluster using the K3s lightweight Kubernetes distribution. The infrastructure is provisioned using Terraform and includes the following components:

- ArgoCD: A GitOps continuous delivery tool for Kubernetes.
- External Secrets: A controller for managing secrets stored in external secret management systems.
- Cilium: Networking and security layer, provides both networking capabilities, such as load balancing and routing, and security features like network policies and endpoint protection.
- HAProxy Ingress: Ingress controller implementation for HAProxy loadbalancer.
- Vault: A secrets management tool for securely storing and accessing sensitive information.
- Github Runners: Runner scale sets is a group of homogeneous runners that can be assigned jobs from GitHub Actions.

## Prerequisites

Before deploying the infrastructure, make sure you have the following prerequisites:

- OpenTofu: Version >= 1.9.0
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

## First Deploy Caveats

During the first deploy of the cluster we need to overcome a [limitation](https://github.com/hashicorp/terraform-provider-kubernetes/issues/2597) of the kubernetes provider.

In order to allow this i had to switch to OpenTofu which adds the `-exclude` plan paramter since version [1.9.0](https://opentofu.org/blog/opentofu-1-9-0/).

```
make plan-custom kub1k OPTIONS='-exclude="module.provision_apps[0].kubernetes_manifest.cilium_lb_pool" -exclude="module.provision_apps[0].kubernetes_manifest.cilium_l2_policy"'
make apply kub1k
```



## ArgoCD Applications

The ArgoCD applications included in this project are:

1. **Cert-Manager**

2. **External-Secrets-Operator**

3. **Lets-Encrypt-Issuers**

4. **Kube-Prometheus-Stack**

5. **Secrets**

6. **Synology-CSI**

## Custom Helm Charts

The Helm charts included in this project are:

1. **ArgoCD-App-of-Apps**: Deploys an ArgoCD application that references other ArgoCD applications, allowing you to manage multiple applications in a centralized manner.

2. **Lets-Encrypt-Issuers**: Necessary resources for setting up Let's Encrypt issuers in cert-manager.

3. **Secrets**: Secrets in your Kubernetes cluster, including the Hetzner API key for cert-manager, ClusterSecretStore, and Synology CSI client info secret.

## License

This project is licensed under the [MIT License](LICENSE).


## Credits

The grafana dashboards are based on the followings projects:

- [Kubernetes Mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin)
- [Prometheus 2.0 Grafana dashboard](https://github.com/FUSAKLA/Prometheus2-grafana-dashboard)
- [Grafana Dashboards K8s](https://github.com/dotdc/grafana-dashboards-kubernetes)
