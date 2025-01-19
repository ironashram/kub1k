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
            --context ${terraform.workspace} \
            --user ${var.ssh_user} \
            --local-path ${var.kube_config_output} \
            --k3s-version ${var.k3s_version} \
            --k3s-extra-args '${local.k3s_extra_args}'
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

resource "null_resource" "k3s_kubeconfig" {
  depends_on = [null_resource.k3s_control]

  provisioner "local-exec" {
    command = <<EOT
            k3sup install \
            --skip-install \
            --ip ${var.control[0].ip} \
            --context ${terraform.workspace} \
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
  name  = "${terraform.workspace}/k3s"
  data_json = jsonencode(
    {
      kubeconfig = base64encode(data.local_sensitive_file.kubeconfig.content)
    }
  )
}
