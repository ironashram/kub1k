resource "null_resource" "k3s_master" {
  depends_on = [
    null_resource.masters_ssh_config
  ]
  for_each = { for master in var.masters : master.name => master }
  provisioner "local-exec" {
    command = <<EOT
            k3sup install \
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
    null_resource.k3s_master
  ]
  for_each = { for worker in var.workers : worker.name => worker }
  provisioner "local-exec" {
    command = <<EOT
            k3sup join \
            --ip ${each.value.ip} \
            --server-ip ${var.masters[0].ip} \
            --ssh-key ${var.ssh_key_file} \
            --user ${var.ssh_user}
        EOT
  }
}
