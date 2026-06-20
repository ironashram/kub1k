locals {
  runner_name  = "${var.cluster_name}-runner"
  runner_owner = data.vault_generic_secret.github.data["owner"]

  runner_env = <<-EOT
    RUNNER_VERSION=${var.runner_version}
    RUNNER_OWNER=${local.runner_owner}
    RUNNER_REPOS=${join(" ", var.runner_repos)}
    RUNNER_LABELS=${var.runner_labels}
  EOT
}

data "ct_config" "runner_ignition" {
  strict = true
  content = templatefile("${path.module}/templates/runner.yaml.tmpl", {
    hostname       = local.runner_name
    mac            = var.runner_mac
    ip             = var.runner_mgmt_ip
    gateway        = "${var.mgmt_ip_base}.1"
    dns1           = var.dns1
    dns2           = var.dns2
    ssh_public_key = local.ssh_public_key
    password_hash  = local.console_password_hash
    repos          = var.runner_repos
    setup_b64      = base64encode(file("${path.module}/files/runner-setup.sh"))
    env_b64        = base64encode(local.runner_env)
    pat_b64        = base64encode(data.vault_generic_secret.runner.data["github_token"])
  })
}

resource "synology_filestation_iso" "runner_ignition" {
  path           = "${var.shared_folder_path}/${local.runner_name}-ign.iso"
  volume_name    = "config-2"
  create_parents = true
  overwrite      = true
  files = [
    {
      path    = "openstack/latest/user_data"
      content = data.ct_config.runner_ignition.rendered
    }
  ]
}

resource "synology_virtualization_image" "runner_ignition_img" {
  name         = "${local.runner_name}-ign"
  path         = synology_filestation_iso.runner_ignition.path
  storage_name = var.flatcar_storage_pool
  image_type   = "iso"
  depends_on   = [synology_filestation_iso.runner_ignition]
}

resource "synology_virtualization_guest" "runner" {
  name         = local.runner_name
  storage_name = var.flatcar_storage_pool
  vcpu_num     = var.runner_vcpu_count
  vram_size    = var.runner_memory_mb
  machine_type = "q35"

  network {
    name  = var.mgmt_network_name
    mac   = var.runner_mac
    model = 1
  }

  disk {
    image_id   = synology_virtualization_image.flatcar.id
    size       = var.runner_disk_mb
    controller = 64
    unmap      = true
  }

  iso {
    image_id = synology_virtualization_image.runner_ignition_img.id
    boot     = false
  }

  run = false
}
