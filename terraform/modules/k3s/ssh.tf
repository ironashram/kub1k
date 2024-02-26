resource "null_resource" "control_ssh_config" {
  for_each = { for master in var.control : master.name => master }

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

resource "null_resource" "worker_ssh_config" {
  for_each = { for worker in var.worker : worker.name => worker }

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
