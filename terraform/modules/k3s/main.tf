resource "null_resource" "k3s_control_primary" {
  triggers = {
    md5_main   = md5(file("${path.module}/main.tf"))
    md5_vars   = md5(file("${path.root}/variables.tf"))
    md5_locals = md5(file("${path.root}/locals.tf"))
  }

  provisioner "local-exec" {
    command = <<EOT
            k3sup install \
            --ip ${var.control_mgmt_ips[0]} \
            --context ${var.cluster_name} \
            --user ${var.ssh_user} \
            --local-path ${var.kube_config_output} \
            --k3s-version ${var.k3s_version} \
            --k3s-extra-args '${var.k3s_extra_args}'
        EOT
  }
}

resource "null_resource" "k3s_control_ha" {
  depends_on = [null_resource.k3s_control_primary]
  count      = length(var.control_mgmt_ips) - 1

  triggers = {
    md5_main   = md5(file("${path.module}/main.tf"))
    md5_vars   = md5(file("${path.root}/variables.tf"))
    md5_locals = md5(file("${path.root}/locals.tf"))
  }

  provisioner "local-exec" {
    command = <<EOT
            k3sup join \
            --server \
            --ip ${var.control_mgmt_ips[count.index + 1]} \
            --server-ip ${var.control_mgmt_ips[0]} \
            --user ${var.ssh_user} \
            --k3s-version ${var.k3s_version} \
            --k3s-extra-args '${var.k3s_server_join_args}'
        EOT
  }
}

resource "null_resource" "k3s_worker" {
  depends_on = [null_resource.k3s_control_primary]
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
  depends_on = [null_resource.k3s_control_primary]

  triggers = {
    md5_main   = md5(file("${path.module}/main.tf"))
    md5_vars   = md5(file("${path.root}/variables.tf"))
    md5_locals = md5(file("${path.root}/locals.tf"))
  }

  provisioner "local-exec" {
    command = <<EOT
            k3sup install \
            --skip-install \
            --ip ${var.control_mgmt_ips[0]} \
            --context ${var.cluster_name} \
            --user ${var.ssh_user} \
            --local-path ${var.kube_config_output} && \
            kubectl --kubeconfig ${var.kube_config_output} config set-cluster ${var.cluster_name} \
            --server=https://${var.control_plane_vip}:6443
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

  data_json_wo_version = parseint(substr(data.local_sensitive_file.kubeconfig.content_md5, 0, 12), 16)
}
