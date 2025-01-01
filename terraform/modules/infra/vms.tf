resource "synology_vmm_guest" "test1" {
  guest_name   = "test1"
  storage_name = var.vm_storage_name
  vram_size    = 2048
  vcpu_num     = 2
  vnics {
    network_name = var.vm_network_name
    #model        = 1
  }
  vdisks {
    create_type = 1
    vdisk_size  = 10240
    image_name  = "k8s_control_01"
  }
}
