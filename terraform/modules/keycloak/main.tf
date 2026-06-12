resource "null_resource" "wait_for_keycloak" {
  triggers = {
    url      = "${var.keycloak_url}/realms/master/.well-known/openid-configuration"
    timeout  = var.wait_timeout_seconds
    interval = var.wait_interval_seconds
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      url='${self.triggers.url}'
      deadline=$(( $(date +%s) + ${self.triggers.timeout} ))
      while : ; do
        if curl -fsS -o /dev/null "$url" ; then
          echo "keycloak reachable at $url"
          exit 0
        fi
        if [ "$(date +%s)" -ge "$deadline" ] ; then
          echo "timed out waiting for $url after ${self.triggers.timeout}s" >&2
          exit 1
        fi
        sleep ${self.triggers.interval}
      done
    EOT
  }
}
