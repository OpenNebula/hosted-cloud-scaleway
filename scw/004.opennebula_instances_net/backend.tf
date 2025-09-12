terraform {
  backend "s3" {
    bucket = var.tfstate
    key    = "terraform-opennebula-instances-net.tfstate"
    region = var.region
    endpoints = {
      s3 = "https://s3.${var.region}.scw.cloud"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    workspace_key_prefix        = "environments"
  }
}
