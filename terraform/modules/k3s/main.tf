

resource "null_resource" "masters_ssh_config" {
  for_each = { for master in var.masters : master.name => master }

  provisioner "local-exec" {
    command = <<COMMAND
cat <<SSHCONFIG > ~/.ssh/config.d/${each.key}
Host ${each.key}
  User ${var.ssh_user}
  Port 22
  HostName ${each.value.ip}
  IdentityFile ${var.ssh_key_file}
SSHCONFIG
COMMAND
  }
}

resource "null_resource" "workers_ssh_config" {
  for_each = { for worker in var.workers : worker.name => worker }

  provisioner "local-exec" {
    command = <<COMMAND
cat <<SSHCONFIG > ~/.ssh/config.d/${each.key}
Host ${each.key}
  User ${var.ssh_user}
  Port 22
  HostName ${each.value.ip}
  IdentityFile ${var.ssh_key_file}
SSHCONFIG
COMMAND
  }
}
