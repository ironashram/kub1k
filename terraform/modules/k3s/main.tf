resource "null_resource" "k3s_control_primary" {
  triggers = {
    md5_main   = md5(file("${path.module}/main.tf"))
    md5_vars   = md5(file("${path.root}/variables.tf"))
    md5_locals = md5(file("${path.root}/locals.tf"))
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      ssh ${var.ssh_user}@${var.control_mgmt_ips[0]} bash <<'REMOTE'
      set -e
      curl -sfL ${var.k3s_install_script_url} | \
        INSTALL_K3S_VERSION='${var.k3s_version}' \
        INSTALL_K3S_SKIP_SELINUX_RPM=true \
        INSTALL_K3S_EXEC='server ${var.k3s_extra_args}' \
        sh -
      REMOTE
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
    command = <<-EOT
      set -e
      TOKEN=$(ssh ${var.ssh_user}@${var.control_mgmt_ips[0]} 'sudo cat /var/lib/rancher/k3s/server/node-token')
      ssh ${var.ssh_user}@${var.control_mgmt_ips[count.index + 1]} bash <<REMOTE
      set -e
      curl -sfL ${var.k3s_install_script_url} | \
        INSTALL_K3S_VERSION='${var.k3s_version}' \
        INSTALL_K3S_SKIP_SELINUX_RPM=true \
        K3S_TOKEN="$TOKEN" \
        INSTALL_K3S_EXEC='server --server https://${var.control_mgmt_ips[0]}:6443 ${var.k3s_server_join_args}' \
        sh -
      REMOTE
    EOT
  }
}

resource "null_resource" "k3s_worker" {
  depends_on = [null_resource.k3s_control_primary]
  count      = length(var.worker_mgmt_ips)

  triggers = {
    md5_main   = md5(file("${path.module}/main.tf"))
    md5_vars   = md5(file("${path.root}/variables.tf"))
    md5_locals = md5(file("${path.root}/locals.tf"))
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      TOKEN=$(ssh ${var.ssh_user}@${var.control_mgmt_ips[0]} 'sudo cat /var/lib/rancher/k3s/server/node-token')
      ssh ${var.ssh_user}@${var.worker_mgmt_ips[count.index]} bash <<REMOTE
      set -e
      curl -sfL ${var.k3s_install_script_url} | \
        INSTALL_K3S_VERSION='${var.k3s_version}' \
        INSTALL_K3S_SKIP_SELINUX_RPM=true \
        K3S_URL='https://${var.control_mgmt_ips[0]}:6443' \
        K3S_TOKEN="$TOKEN" \
        sh -
      REMOTE
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
    command = <<-EOT
      set -e
      ssh ${var.ssh_user}@${var.control_mgmt_ips[0]} 'sudo cat /etc/rancher/k3s/k3s.yaml' | \
        sed -e 's|https://127\.0\.0\.1:6443|https://${var.control_plane_vip}:6443|' \
            -e 's|: default$|: ${var.cluster_name}|' > ${var.kube_config_output}
      chmod 600 ${var.kube_config_output}
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
