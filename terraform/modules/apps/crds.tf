resource "helm_release" "crds" {

  name              = "crds"
  chart             = "${path.root}/../charts/crds"
  namespace         = "default"
  dependency_update = true

}
