output "kubeconfig" {
  value     = module.provision_k3s.kubeconfig
  sensitive = true
}
