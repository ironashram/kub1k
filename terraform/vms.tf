resource "synology_filestation_file" "ubuntu_image" {
  path           = "${var.shared_folder_path}/ubuntu-24.04-server-cloudimg-amd64.img"
  url            = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  create_parents = true
}

resource "synology_virtualization_image" "ubuntu_noble" {
  name         = "ubuntu-noble-cloud-${var.cluster_name}"
  path         = synology_filestation_file.ubuntu_image.path
  storage_name = var.storage_pool
  image_type   = "disk"
  depends_on   = [synology_filestation_file.ubuntu_image]
}

resource "synology_filestation_cloud_init" "control_init" {
  count          = var.control_count
  path           = "${var.shared_folder_path}/${var.cluster_name}-control-${count.index + 1}-init.iso"
  create_parents = true
  overwrite      = true
  user_data      = <<EOF
#cloud-config
hostname: ${var.cluster_name}-control-${count.index + 1}.${local.domain_name}
users:
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ${local.ssh_public_key}
package_update: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl start qemu-guest-agent
EOF
  network_config = <<EOF
version: 2
ethernets:
  eth0:
    match:
      macaddress: "${local.control_mgmt_macs[count.index]}"
    set-name: eth0
    addresses:
      - "${var.mgmt_ip_base}.${count.index + 11}/24"
    gateway4: "${var.mgmt_ip_base}.1"
    nameservers:
      addresses:
        - ${var.dns1}
        - ${var.dns2}
    dhcp4: false
    dhcp6: false
EOF
}

resource "synology_virtualization_image" "control_init_img" {
  count        = var.control_count
  name         = "${var.cluster_name}-control-${count.index + 1}-init"
  path         = synology_filestation_cloud_init.control_init[count.index].path
  storage_name = var.storage_pool
  image_type   = "iso"
  depends_on   = [synology_filestation_cloud_init.control_init]
}

resource "synology_virtualization_guest" "control_nodes" {
  count        = var.control_count
  name         = "${var.cluster_name}-control-${count.index + 1}"
  storage_name = var.storage_pool
  vcpu_num     = var.control_vcpu_count
  vram_size    = var.control_memory_mb

  network {
    name = var.mgmt_network_name
    mac  = local.control_mgmt_macs[count.index]
  }

  disk {
    image_id = synology_virtualization_image.ubuntu_noble.id
    size     = var.control_disk_mb
  }

  iso {
    image_id = synology_virtualization_image.control_init_img[count.index].id
    boot     = false
  }

  run = false
}

resource "synology_filestation_cloud_init" "worker_init" {
  count          = var.worker_count
  path           = "${var.shared_folder_path}/${var.cluster_name}-worker-${count.index + 1}-init.iso"
  create_parents = true
  overwrite      = true
  user_data      = <<EOF
#cloud-config
hostname: ${var.cluster_name}-worker-${count.index + 1}.${local.domain_name}
users:
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ${local.ssh_public_key}
package_update: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl start qemu-guest-agent
EOF
  network_config = <<EOF
version: 2
ethernets:
  eth0:
    match:
      macaddress: "${local.worker_mgmt_macs[count.index]}"
    set-name: eth0
    addresses:
      - "${var.mgmt_ip_base}.${count.index + 21}/24"
    gateway4: "${var.mgmt_ip_base}.1"
    nameservers:
      addresses:
        - ${var.dns1}
        - ${var.dns2}
    dhcp4: false
    dhcp6: false
EOF
}

resource "synology_virtualization_image" "worker_init_img" {
  count        = var.worker_count
  name         = "${var.cluster_name}-worker-${count.index + 1}-init"
  path         = synology_filestation_cloud_init.worker_init[count.index].path
  storage_name = var.storage_pool
  image_type   = "iso"
  depends_on   = [synology_filestation_cloud_init.worker_init]
}

resource "synology_virtualization_guest" "worker_nodes" {
  count        = var.worker_count
  name         = "${var.cluster_name}-worker-${count.index + 1}"
  storage_name = var.storage_pool
  vcpu_num     = var.worker_vcpu_count
  vram_size    = var.worker_memory_mb
  network {
    name = var.mgmt_network_name
    mac  = local.worker_mgmt_macs[count.index]
  }

  disk {
    image_id = synology_virtualization_image.ubuntu_noble.id
    size     = var.worker_disk_mb
  }

  iso {
    image_id = synology_virtualization_image.worker_init_img[count.index].id
    boot     = false
  }

  run = false
}
