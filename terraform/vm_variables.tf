variable "storage_pool" {
  type        = string
  default     = "k8storage"
  description = "Name of the storage pool in Synology VMM"
}

variable "mgmt_network_name" {
  type        = string
  default     = "k8s-mgmt"
  description = "Name of the management network in Synology VMM"
}

variable "shared_folder_path" {
  type        = string
  default     = "/NAS/terraform"
  description = "Path to the shared folder on Synology NAS for images"
}

variable "mgmt_ip_base" {
  type        = string
  default     = "10.78.0"
  description = "Base IP for management network (e.g., 192.168.100)"
}

variable "control_count" {
  type        = number
  default     = 1
  description = "Number of control nodes to create"
}

variable "worker_count" {
  type        = number
  default     = 2
  description = "Number of worker nodes to create"
}

variable "worker_memory_mb" {
  type        = number
  default     = 8192
  description = "Amount of memory (in MB) for each worker node"
}

variable "worker_vcpu_count" {
  type        = number
  default     = 4
  description = "Number of vCPUs for each worker node"
}

variable "control_memory_mb" {
  type        = number
  default     = 8192
  description = "Amount of memory (in MB) for each control node"
}

variable "control_vcpu_count" {
  type        = number
  default     = 4
  description = "Number of vCPUs for each control node"
}

variable "worker_disk_mb" {
  type        = number
  default     = 102400
  description = "Disk size (in MB) for each worker node"
}

variable "control_disk_mb" {
  type        = number
  default     = 102400
  description = "Disk size (in MB) for each control node"
}

variable "dns1" {
  type    = string
  default = "1.1.1.1"
}

variable "dns2" {
  type    = string
  default = "8.8.8.8"
}
