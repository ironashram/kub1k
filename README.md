[![Terraform Plan](https://github.com/ironashram/kub1k/actions/workflows/terraform-plan.yaml/badge.svg)](https://github.com/ironashram/kub1k/actions/workflows/terraform-plan.yaml)
[![Terraform Apply](https://github.com/ironashram/kub1k/actions/workflows/terraform-apply.yaml/badge.svg)](https://github.com/ironashram/kub1k/actions/workflows/terraform-apply.yaml)

# kub1k

<p align="left">
  <img src="assets/kub1k.png" alt="kub1k ScreenShot" width="800">
</p>


The name comes from a silly portmanteau between kube and m1k (my nickname) <br>
This repository contains the Terraform code for deploying and managing a homelab k8s infrastructure.

## Overview

The kub1k project aims to provide a scalable and reliable Kubernetes cluster using the K3s lightweight Kubernetes distribution. The infrastructure is provisioned using Terraform and includes the following components:

- ArgoCD
- External Secrets
- Cilium
- HAProxy Ingress
- Vault
- Github Runners
- Kube-Prometheus-Stack
- Cert-Manager
- External-Secrets-Operator
- Synology-CSI
- Custom Helm charts (deployed as ArgoCD applications)

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

<details>
<summary>First Deploy Caveats (Deprecated)</summary>

During the first deploy of the cluster we need to overcome a [limitation](https://github.com/hashicorp/terraform-provider-kubernetes/issues/2597) of the kubernetes provider.

In order to allow this i had to switch to OpenTofu which adds the `-exclude` plan paramter since version [1.9.0](https://opentofu.org/blog/opentofu-1-9-0/).

```
make plan-custom kub1k OPTIONS='-exclude="module.provision_apps[0].kubernetes_manifest.cilium_lb_pool" -exclude="module.provision_apps[0].kubernetes_manifest.cilium_l2_policy"'
make apply kub1k
```
</details>

## License

This project is licensed under the [MIT License](LICENSE).


## Credits

The grafana dashboards are based on the followings projects:

- [Kubernetes Mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin)
- [Prometheus 2.0 Grafana dashboard](https://github.com/FUSAKLA/Prometheus2-grafana-dashboard)
- [Grafana Dashboards K8s](https://github.com/dotdc/grafana-dashboards-kubernetes)
