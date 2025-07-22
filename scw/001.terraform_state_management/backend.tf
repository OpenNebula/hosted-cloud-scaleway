###

# First init a local terraform state with all the project ids / access_key / secret_key

## Then uncomment backend S3

## Create a profile in your ~/.aws/credentials with a profile, by example :

## Then run a terraform / tofu init -migrate-state

## Fix 403 forbidden error by adding the right policy to the bucket on your Scaleway account used

# terraform {
#   backend "s3" {
#     bucket = var.state_infrastructure_information.scw_state_bucket
#     key    = "global/terraform-state-management"
#     region = var.state_infrastructure_information.scw_state_region
#     endpoints = {
#       s3 = "https://s3.${var.state_infrastructure_information.scw_state_region}.scw.cloud"
#     }
#     skip_region_validation      = true
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     skip_requesting_account_id  = true
#     skip_s3_checksum            = true
#     profile                     = var.state_infrastructure_information.scw_profile
#   }
# }
