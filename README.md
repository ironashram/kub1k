### Fully automated k8s cluster

```
.
├── apps
│   ├── Chart.yaml
│   ├── templates
│   │   ├── cert-manager.yaml
│   │   ├── external-secrets-operator.yaml
│   │   ├── _helpers.tpl
│   │   ├── lets-encrypt-issuers.yaml
│   │   ├── metallb-cr.yaml
│   │   ├── prometheus-operator.yaml
│   │   ├── secrets.yaml
│   │   └── synology-csi.yaml
│   └── values.yaml
├── charts
│   ├── argocd-app-of-apps
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   ├── application.yaml
│   │   │   └── _helpers.tpl
│   │   └── values.yaml
│   ├── lets-encrypt-issuers
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   └── cluster-issuer.yaml
│   │   └── values.yaml
│   ├── metallb-cr
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   └── metallb-cr.yaml
│   │   └── values.yaml
│   └── secrets
│       ├── Chart.yaml
│       ├── templates
│       │   ├── cert-manager
│       │   │   └── cloudflare-api-key.yaml
│       │   ├── clustersecretstore.yaml
│       │   └── synology-csi
│       │       └── client-info-secret.yaml
│       └── values.yaml
├── Makefile
├── README.md
└── terraform
    ├── apps.tf
    ├── helper.sh
    ├── k3s.tf
    ├── kubeconfig.tf
    ├── locals.tf
    ├── main.tf
    ├── modules
    │   ├── apps
    │   │   ├── apps.tf
    │   │   ├── argocd.tf
    │   │   ├── calico.tf
    │   │   ├── external_secrets.tf
    │   │   ├── metallb.tf
    │   │   ├── nginx.tf
    │   │   ├── providers.tf
    │   │   └── variables.tf
    │   └── k3s
    │       ├── main.tf
    │       ├── ssh.tf
    │       └── variables.tf
    ├── providers.tf
    ├── variables.tf
    ├── vault.tf
    └── versions.tf
```
