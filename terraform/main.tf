terraform {
  backend "s3" {
    region = "custom"
    endpoints = {
      s3 = "https://${var.remote_state_s3_endpoint}"
    }
    bucket                      = "tfdata-v2"
    key                         = "terraform.tfstate"
    workspace_key_prefix        = "k8s"
    use_path_style              = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}
