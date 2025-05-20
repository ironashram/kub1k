resource "helm_release" "crds" {

  name              = "crds"
  chart             = "${path.root}/../charts/crds"
  namespace         = "default"
  dependency_update = true

  lifecycle {
    replace_triggered_by = [null_resource.src_crds]
  }
}

data "archive_file" "crds" {

  type        = "zip"
  source_dir  = "${path.root}/../charts/crds"
  output_path = "${path.root}/.terraform/crds.zip"
}

resource "null_resource" "src_crds" {
  triggers = {
    src_sha = data.archive_file.crds.output_sha
  }
}
