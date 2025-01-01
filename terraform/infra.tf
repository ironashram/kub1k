/*****************
  Provision Infra
*****************/
module "provision_infra" {
  source = "./modules/infra"

  vm_storage_name = var.vm_storage_name
  vm_network_name = var.vm_network_name

  providers = {
    synology = synology
  }
}
