variable "runner_repos" {
  type        = list(string)
  default     = ["kub1k", "commstack", "metapac", "m1k.cloud"]
  description = "Repos (under the github owner) to register a self-hosted runner for on the runner VM"
}

variable "runner_version" {
  type        = string
  default     = "2.335.1"
  description = "GitHub Actions runner agent version (without the leading v)"
}

variable "runner_labels" {
  type        = string
  default     = "self-hosted,kub1k-vm"
  description = "Comma-separated labels applied to every runner (the repo name is appended per runner)"
}

variable "runner_mgmt_ip" {
  type        = string
  default     = "10.78.0.30"
  description = "Static management-network IP for the runner VM"
}

variable "runner_mac" {
  type        = string
  default     = "02:00:00:a1:22:01"
  description = "MAC for the runner VM management NIC"
}

variable "runner_vcpu_count" {
  type    = number
  default = 2
}

variable "runner_memory_mb" {
  type    = number
  default = 4096
}

variable "runner_disk_mb" {
  type    = number
  default = 51200
}
