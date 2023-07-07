/*****************************
  S3 State Configuration
*****************************/
terraform {
  backend "s3" {
    region                      = "us-west-1"
    endpoint                    = "s3.lab.m1k.cloud"
    bucket                      = "terraform-backend"
    key                         = "terraform.tfstate"
    workspace_key_prefix        = "infra-mgmt-cluster"
    encrypt                     = true
    force_path_style            = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}
