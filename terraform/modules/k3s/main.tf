resource "null_resource" "k3s_control" {
  depends_on = [
    null_resource.control_ssh_config
  ]
  for_each = { for master in var.control : master.name => master }
  provisioner "local-exec" {
    command = <<EOT
            sudo k3sup install \
            --ip ${each.value.ip} \
            --context ${var.kube_context} \
            --ssh-key ${var.ssh_key_file} \
            --user ${var.ssh_user} \
            --local-path ${var.kube_config_output} \
            --k3s-extra-args '${var.k3s_extra_args}'
        EOT
  }
}

resource "null_resource" "k3s_worker" {
  depends_on = [
    null_resource.k3s_control
  ]
  for_each = { for worker in var.worker : worker.name => worker }
  provisioner "local-exec" {
    command = <<EOT
            sudo k3sup join \
            --ip ${each.value.ip} \
            --server-ip ${var.control[0].ip} \
            --ssh-key ${var.ssh_key_file} \
            --user ${var.ssh_user}
        EOT
  }
}
