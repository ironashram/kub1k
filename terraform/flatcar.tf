resource "synology_filestation_file" "flatcar_image" {
  path           = "${var.shared_folder_path}/flatcar_${var.flatcar_version}_openstack.img"
  url            = "https://${var.flatcar_channel}.release.flatcar-linux.net/amd64-usr/${var.flatcar_version}/flatcar_production_openstack_image.img"
  create_parents = true
}

resource "synology_virtualization_image" "flatcar" {
  name         = "flatcar-${var.flatcar_version}-${var.cluster_name}"
  path         = synology_filestation_file.flatcar_image.path
  storage_name = var.flatcar_storage_pool
  image_type   = "disk"
  depends_on   = [synology_filestation_file.flatcar_image]
}
