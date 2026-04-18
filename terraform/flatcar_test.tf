locals {
  flatcar_test_hostname = "${var.cluster_name}-flatcar-test"
  flatcar_test_ip       = "${var.mgmt_ip_base}.99"
  flatcar_test_mac      = "02:00:00:a1:99:01"
}

data "ct_config" "flatcar_test" {
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
              ${local.flatcar_test_hostname}
        - path: /etc/systemd/network/10-eth0.network
          mode: 0644
          overwrite: true
          contents:
            inline: |
              [Match]
              MACAddress=${local.flatcar_test_mac}
              [Link]
              RequiredForOnline=yes
              [Network]
              Address=${local.flatcar_test_ip}/24
              Gateway=${var.mgmt_ip_base}.1
              DNS=${var.dns1}
              DNS=${var.dns2}
        - path: /etc/flatcar/update.conf
          mode: 0644
          overwrite: true
          contents:
            inline: |
              REBOOT_STRATEGY=off
    systemd:
      units:
        - name: qemu-guest-agent.service
          enabled: true
        - name: flatcar-openstack-hostname.service
          mask: true
  EOT
}

resource "synology_filestation_iso" "flatcar_test_ign" {
  path           = "${var.shared_folder_path}/${local.flatcar_test_hostname}-ign.iso"
  volume_name    = "config-2"
  create_parents = true
  overwrite      = true
  files = [
    {
      path    = "openstack/latest/user_data"
      content = data.ct_config.flatcar_test.rendered
    }
  ]
}

resource "synology_virtualization_image" "flatcar_test_ign" {
  name         = "${local.flatcar_test_hostname}-ign"
  path         = synology_filestation_iso.flatcar_test_ign.path
  storage_name = var.flatcar_storage_pool
  image_type   = "iso"
  depends_on   = [synology_filestation_iso.flatcar_test_ign]
}

resource "synology_virtualization_guest" "flatcar_test" {
  name         = local.flatcar_test_hostname
  storage_name = var.flatcar_storage_pool
  vcpu_num     = 2
  vram_size    = 2048
  machine_type = "q35"

  network {
    name  = var.mgmt_network_name
    mac   = local.flatcar_test_mac
    model = 1
  }

  disk {
    image_id   = synology_virtualization_image.flatcar.id
    size       = 20480
    controller = 64
    unmap      = true
  }

  iso {
    image_id = synology_virtualization_image.flatcar_test_ign.id
    boot     = false
  }

  run = false
}
