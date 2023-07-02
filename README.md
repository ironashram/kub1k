### k3s cluster on synology virtual machine manager

After applying terraform finish setup with the follwoing steps

```
k create namespace tigera-operator
helm install calico projectcalico/tigera-operator --version v3.25.0 --namespace tigera-operator
helm install metallb metallb/metallb -n metallb --create-namespace

cd manifests
k apply -f custom-resources.yaml
k apply -f pool.yaml -f l2.yaml

helm install prometheus-operator prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
helm install nginx-ingress nginx-stable/nginx-ingress --namespace nginx-ingress --create-namespace

k apply -f ingress_grafana.yaml -f ingress_prometheus.yaml
```


helm upgrade --install vault-operator banzaicloud-stable/vault-operator -n vault --create-namespace


kubectl apply -f https://raw.githubusercontent.com/bank-vaults/vault-operator/main/deploy/default/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/bank-vaults/vault-operator/main/deploy/examples/cr.yaml
