locals {
  kube_config_output = pathexpand("~/.kube/config-files/lab/${var.cluster_name}.yaml")

  // decode base64 kubeconfig from vault
  kubeconfig             = try(yamldecode(base64decode(data.vault_generic_secret.k3s.data["kubeconfig"])), null)
  cluster_host           = try(local.kubeconfig.clusters[0].cluster.server, null)
  cluster_ca_certificate = try(base64decode(local.kubeconfig.clusters[0].cluster.certificate-authority-data), null)
  client_certificate     = try(base64decode(local.kubeconfig.users[0].user.client-certificate-data), null)
  client_key             = try(base64decode(local.kubeconfig.users[0].user.client-key-data), null)

  k3s_extra_args = join(" ", [
    "--cluster-cidr=${var.k3s_cluster_cidr}",
    "--service-cidr=${var.k3s_service_cidr}",
    "--cluster-dns=${var.k3s_cluster_dns}",
    "--cluster-init",
    "--etcd-expose-metrics",
    "--kube-controller-manager-arg=bind-address=${var.k3s_kube_bind_address}",
    "--kube-proxy-arg=metrics-bind-address=${var.k3s_kube_bind_address}",
    "--kube-scheduler-arg=bind-address=${var.k3s_kube_bind_address}",
    "--flannel-backend=none",
    "--disable-kube-proxy",
    "--disable-network-policy",
    "--disable=traefik",
    "--disable=servicelb",
    "--disable=coredns",
    "--tls-san=${var.control_plane_vip}"
  ])

  k3s_server_join_args = join(" ", [
    "--cluster-cidr=${var.k3s_cluster_cidr}",
    "--service-cidr=${var.k3s_service_cidr}",
    "--cluster-dns=${var.k3s_cluster_dns}",
    "--etcd-expose-metrics",
    "--kube-controller-manager-arg=bind-address=${var.k3s_kube_bind_address}",
    "--kube-proxy-arg=metrics-bind-address=${var.k3s_kube_bind_address}",
    "--kube-scheduler-arg=bind-address=${var.k3s_kube_bind_address}",
    "--flannel-backend=none",
    "--disable-kube-proxy",
    "--disable-network-policy",
    "--disable=traefik",
    "--disable=servicelb",
    "--disable=coredns",
    "--tls-san=${var.control_plane_vip}"
  ])

  control_mgmt_macs = [for i in range(var.control_count) : format("02:00:00:a1:00:%02x", i + 1)]
  control_mgmt_ips  = [for i in range(var.control_count) : "${var.mgmt_ip_base}.${i + 11}"]
  control_names     = [for i in range(var.control_count) : "${var.cluster_name}-control-${i + 1}"]
  worker_mgmt_macs  = [for i in range(var.worker_count) : format("02:00:00:a1:11:%02x", i + 1)]
  worker_mgmt_ips   = [for i in range(var.worker_count) : "${var.mgmt_ip_base}.${i + 21}"]
  worker_names      = [for i in range(var.worker_count) : "${var.cluster_name}-worker-${i + 1}"]

  # When label_controls_as_worker=true, control nodes also receive the worker role label
  # so workloads with nodeSelector node-role.kubernetes.io/worker continue to schedule
  worker_label_names = var.label_controls_as_worker ? concat(local.control_names, local.worker_names) : local.worker_names

  domain_name    = data.vault_generic_secret.vars.data["domain_name"]
  ssh_public_key = data.vault_generic_secret.vars.data["ssh_public_key"]

  flatcar_ignition_tmpl = <<-EOT
    variant: flatcar
    version: 1.0.0
    passwd:
      users:
        - name: core
          ssh_authorized_keys:
            - $${ssh_public_key}
    storage:
      files:
        - path: /etc/hostname
          mode: 0644
          overwrite: true
          contents:
            inline: |
              $${hostname}
        - path: /etc/systemd/network/10-eth0.network
          mode: 0644
          overwrite: true
          contents:
            inline: |
              [Match]
              MACAddress=$${mac}
              [Link]
              RequiredForOnline=yes
              [Network]
              Address=$${ip}/24
              Gateway=$${gateway}
              DNS=$${dns1}
              DNS=$${dns2}
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
        - name: sshkeys.service
          mask: true
        - name: coreos-metadata-sshkeys@core.service
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
