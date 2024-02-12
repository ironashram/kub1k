resource "null_resource" "kubeconfig" {
  triggers = {
    kube_config_output = local.kube_config_output
  }

  provisioner "local-exec" {
    command = "test ! -f ${self.triggers.kube_config_output} && echo '---' > ${self.triggers.kube_config_output} || true"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${self.triggers.kube_config_output}"
  }
}
