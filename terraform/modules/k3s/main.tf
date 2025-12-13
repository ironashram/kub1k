resource "null_resource" "k3s_control" {
  triggers = {
    md5_main   = md5(file("${path.module}/main.tf"))
    md5_vars   = md5(file("${path.root}/variables.tf"))
    md5_locals = md5(file("${path.root}/locals.tf"))
  }

  count = length(var.control_mgmt_ips)
  provisioner "local-exec" {
    command = <<EOT
            k3sup install \
            --ip ${var.control_mgmt_ips[count.index]} \
            --context ${var.cluster_name} \
            --user ${var.ssh_user} \
            --local-path ${var.kube_config_output} \
            --k3s-version ${var.k3s_version} \
            --k3s-extra-args '${var.k3s_extra_args}'
        EOT
  }
}

resource "null_resource" "k3s_worker" {
  depends_on = [null_resource.k3s_control]
  triggers = {
    md5_main   = md5(file("${path.module}/main.tf"))
    md5_vars   = md5(file("${path.root}/variables.tf"))
    md5_locals = md5(file("${path.root}/locals.tf"))
  }

  count = length(var.worker_mgmt_ips)
  provisioner "local-exec" {
    command = <<EOT
            k3sup join \
            --ip ${var.worker_mgmt_ips[count.index]} \
            --server-ip ${var.control_mgmt_ips[0]} \
            --user ${var.ssh_user} \
            --k3s-version ${var.k3s_version}
        EOT
  }
}

resource "null_resource" "k3s_kubeconfig" {
  depends_on = [null_resource.k3s_control]

  provisioner "local-exec" {
    command = <<EOT
            k3sup install \
            --skip-install \
            --ip ${var.control_mgmt_ips[0]} \
            --context ${var.cluster_name} \
            --user ${var.ssh_user} \
            --local-path ${var.kube_config_output}
        EOT
  }
}

data "local_sensitive_file" "kubeconfig" {
  depends_on = [null_resource.k3s_kubeconfig]
  filename   = var.kube_config_output
}


resource "vault_kv_secret_v2" "k3s" {
  mount = "kv"
  name  = "${var.cluster_name}/k3s"
  data_json_wo = jsonencode(
    {
      kubeconfig = base64encode(data.local_sensitive_file.kubeconfig.content)
    }
  )
  # Use filemd5 to get the hash during plan if the file exists, avoiding deferred value drift
  data_json_wo_version = parseint(substr(try(filemd5(var.kube_config_output), md5("wait")), 0, 12), 16)
}
