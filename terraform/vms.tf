data "ct_config" "control_ignition" {
  count  = var.control_count
  strict = true
  content = <<-EOT
    variant: flatcar
    version: 1.0.0
    passwd:
      users:
        - name: core
          ssh_authorized_keys:
            - ${local.ssh_public_key}
    storage:
      files:
        - path: /etc/hostname
          mode: 0644
          overwrite: true
          contents:
            inline: |
              ${var.cluster_name}-control-${count.index + 1}
        - path: /etc/systemd/network/10-eth0.network
          mode: 0644
          overwrite: true
          contents:
            inline: |
              [Match]
              MACAddress=${local.control_mgmt_macs[count.index]}
              [Link]
              RequiredForOnline=yes
              [Network]
              Address=${var.mgmt_ip_base}.${count.index + 11}/24
              Gateway=${var.mgmt_ip_base}.1
              DNS=${var.dns1}
              DNS=${var.dns2}
        - path: /etc/flatcar/update.conf
          mode: 0644
          overwrite: true
          contents:
            inline: |
              REBOOT_STRATEGY=off
        - path: /etc/ssh/sshd_config.d/00-post-quantum-kex.conf
          mode: 0644
          overwrite: true
          contents:
            inline: |
              KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256
    systemd:
      units:
        - name: qemu-guest-agent.service
          enabled: true
        - name: flatcar-openstack-hostname.service
          mask: true
        - name: iscsi-init.service
          enabled: true
          contents: |
            [Unit]
            Description=Generate iSCSI initiator name on first boot
            Before=iscsid.service
            ConditionPathExists=!/etc/iscsi/initiatorname.iscsi
            [Service]
            Type=oneshot
            RemainAfterExit=true
            ExecStart=/bin/sh -c 'mkdir -p /etc/iscsi && echo "InitiatorName=$(/sbin/iscsi-iname)" > /etc/iscsi/initiatorname.iscsi'
            [Install]
            WantedBy=multi-user.target
        - name: iscsid.service
          enabled: true
  EOT
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
  content = <<-EOT
    variant: flatcar
    version: 1.0.0
    passwd:
      users:
        - name: core
          ssh_authorized_keys:
            - ${local.ssh_public_key}
    storage:
      files:
        - path: /etc/hostname
          mode: 0644
          overwrite: true
          contents:
            inline: |
              ${var.cluster_name}-worker-${count.index + 1}
        - path: /etc/systemd/network/10-eth0.network
          mode: 0644
          overwrite: true
          contents:
            inline: |
              [Match]
              MACAddress=${local.worker_mgmt_macs[count.index]}
              [Link]
              RequiredForOnline=yes
              [Network]
              Address=${var.mgmt_ip_base}.${count.index + 21}/24
              Gateway=${var.mgmt_ip_base}.1
              DNS=${var.dns1}
              DNS=${var.dns2}
        - path: /etc/flatcar/update.conf
          mode: 0644
          overwrite: true
          contents:
            inline: |
              REBOOT_STRATEGY=off
        - path: /etc/ssh/sshd_config.d/00-post-quantum-kex.conf
          mode: 0644
          overwrite: true
          contents:
            inline: |
              KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256
    systemd:
      units:
        - name: qemu-guest-agent.service
          enabled: true
        - name: flatcar-openstack-hostname.service
          mask: true
        - name: iscsi-init.service
          enabled: true
          contents: |
            [Unit]
            Description=Generate iSCSI initiator name on first boot
            Before=iscsid.service
            ConditionPathExists=!/etc/iscsi/initiatorname.iscsi
            [Service]
            Type=oneshot
            RemainAfterExit=true
            ExecStart=/bin/sh -c 'mkdir -p /etc/iscsi && echo "InitiatorName=$(/sbin/iscsi-iname)" > /etc/iscsi/initiatorname.iscsi'
            [Install]
            WantedBy=multi-user.target
        - name: iscsid.service
          enabled: true
  EOT
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
