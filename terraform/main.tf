terraform {
  backend "s3" {
    region = "us-east-1"
    endpoints = {
      s3 = "https://${var.remote_state_s3_endpoint}"
    }
    bucket                      = "tfdata-v2"
    key                         = "k8s/terraform.tfstate"
    use_path_style              = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}
