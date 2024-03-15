resource "null_resource" "k3s_control" {
  triggers = {
    md5_main = md5(file("${path.module}/main.tf"))
    md5_vars = md5(file("${path.root}/variables.tf"))
  }

  for_each = { for master in var.control : master.name => master }
  provisioner "local-exec" {
    command = <<EOT
            k3sup install \
            --ip ${each.value.ip} \
            --context ${var.kube_context} \
            --user ${var.ssh_user} \
            --local-path ${var.kube_config_output} \
            --k3s-extra-args '${var.k3s_extra_args}' \
            --k3s-version ${var.k3s_version}
        EOT
  }
}

resource "null_resource" "k3s_worker" {
  depends_on = [null_resource.k3s_control]
  triggers = {
    md5_main = md5(file("${path.module}/main.tf"))
    md5_vars = md5(file("${path.root}/variables.tf"))
  }

  for_each = { for worker in var.worker : worker.name => worker }
  provisioner "local-exec" {
    command = <<EOT
            k3sup join \
            --ip ${each.value.ip} \
            --server-ip ${var.control[0].ip} \
            --user ${var.ssh_user} \
            --k3s-version ${var.k3s_version}
        EOT
  }
}
