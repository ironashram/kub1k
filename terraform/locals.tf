locals {
  kube_config_path_home      = "~/.kube/config-files/${terraform.workspace}.yaml"
  kube_config_path_workspace = "$GITHUB_WORKSPACE/.kube/config-files/${terraform.workspace}.yaml"

  kubeconfig_home      = try(yamldecode(file(pathexpand(local.kube_config_path_home))), "")
  kubeconfig_workspace = try(yamldecode(file(pathexpand(local.kube_config_path_workspace))), "")

  kubeconfig = coalesce(local.kubeconfig_home, local.kubeconfig_workspace)

  kube_config_output = local.kubeconfig == local.kubeconfig_home ? pathexpand(local.kube_config_path_home) : pathexpand(local.kube_config_path_workspace)

  cluster_host           = try(local.kubeconfig.clusters[0].cluster.server, null)
  cluster_ca_certificate = try(base64decode(local.kubeconfig.clusters[0].cluster.certificate-authority-data), null)
  client_certificate     = try(base64decode(local.kubeconfig.users[0].user.client-certificate-data), null)
  client_key             = try(base64decode(local.kubeconfig.users[0].user.client-key-data), null)
}

resource "null_resource" "print_paths" {
  provisioner "local-exec" {
    command = "echo Home path: ${pathexpand(local.kube_config_path_home)}; echo Workspace path: ${pathexpand(local.kube_config_path_workspace)}"
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}
