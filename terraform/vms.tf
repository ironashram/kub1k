data "ct_config" "control_ignition" {
  count  = var.control_count
  strict = true
  content = templatestring(local.flatcar_ignition_tmpl, {
    hostname       = local.control_names[count.index]
    mac            = local.control_mgmt_macs[count.index]
    ip             = local.control_mgmt_ips[count.index]
    gateway        = "${var.mgmt_ip_base}.1"
    dns1           = var.dns1
    dns2           = var.dns2
    ssh_public_key = local.ssh_public_key
  })
}

resource "synology_filestation_iso" "control_ignition" {
  count          = var.control_count
  path           = "${var.shared_folder_path}/${var.cluster_name}-control-${count.index + 1}-ign.iso"
  volume_name    = "config-2"
  create_parents = true
  overwrite      = true
  files = [
    {
      path    = "openstack/latest/user_data"
      content = data.ct_config.control_ignition[count.index].rendered
    }
  ]
}

resource "synology_virtualization_image" "control_ignition_img" {
  count        = var.control_count
  name         = "${var.cluster_name}-control-${count.index + 1}-ign"
  path         = synology_filestation_iso.control_ignition[count.index].path
  storage_name = var.flatcar_storage_pool
  image_type   = "iso"
  depends_on   = [synology_filestation_iso.control_ignition]
}

resource "synology_virtualization_guest" "control_nodes" {
  count        = var.control_count
  name         = "${var.cluster_name}-control-${count.index + 1}"
  storage_name = var.flatcar_storage_pool
  vcpu_num     = var.control_vcpu_count
  vram_size    = var.control_memory_mb
  machine_type = "q35"

  network {
    name  = var.mgmt_network_name
    mac   = local.control_mgmt_macs[count.index]
    model = 1
  }

  disk {
    image_id   = synology_virtualization_image.flatcar.id
    size       = var.control_disk_mb
    controller = 64
    unmap      = true
  }

  iso {
    image_id = synology_virtualization_image.control_ignition_img[count.index].id
    boot     = false
  }

  run = false
}

data "ct_config" "worker_ignition" {
  count  = var.worker_count
  strict = true
  content = templatestring(local.flatcar_ignition_tmpl, {
    hostname       = local.worker_names[count.index]
    mac            = local.worker_mgmt_macs[count.index]
    ip             = local.worker_mgmt_ips[count.index]
    gateway        = "${var.mgmt_ip_base}.1"
    dns1           = var.dns1
    dns2           = var.dns2
    ssh_public_key = local.ssh_public_key
  })
}

resource "synology_filestation_iso" "worker_ignition" {
  count          = var.worker_count
  path           = "${var.shared_folder_path}/${var.cluster_name}-worker-${count.index + 1}-ign.iso"
  volume_name    = "config-2"
  create_parents = true
  overwrite      = true
  files = [
    {
      path    = "openstack/latest/user_data"
      content = data.ct_config.worker_ignition[count.index].rendered
    }
  ]
}

resource "synology_virtualization_image" "worker_ignition_img" {
  count        = var.worker_count
  name         = "${var.cluster_name}-worker-${count.index + 1}-ign"
  path         = synology_filestation_iso.worker_ignition[count.index].path
  storage_name = var.flatcar_storage_pool
  image_type   = "iso"
  depends_on   = [synology_filestation_iso.worker_ignition]
}

resource "synology_virtualization_guest" "worker_nodes" {
  count        = var.worker_count
  name         = "${var.cluster_name}-worker-${count.index + 1}"
  storage_name = var.flatcar_storage_pool
  vcpu_num     = var.worker_vcpu_count
  vram_size    = var.worker_memory_mb
  machine_type = "q35"

  network {
    name  = var.mgmt_network_name
    mac   = local.worker_mgmt_macs[count.index]
    model = 1
  }

  disk {
    image_id   = synology_virtualization_image.flatcar.id
    size       = var.worker_disk_mb
    controller = 64
    unmap      = true
  }

  iso {
    image_id = synology_virtualization_image.worker_ignition_img[count.index].id
    boot     = false
  }

  run = false
}
