/*****************************
  S3 State Configuration
*****************************/
terraform {
  backend "s3" {
    region = "s3-m1k-cloud"
    endpoints = {
      s3 = "https://s3.m1k.cloud"
    }
    bucket                      = "tfdata"
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
