# Configure the Scaleway provider
provider "scaleway" {
  region          = var.state_infrastructure_information.scw_state_region
  zone            = var.state_infrastructure_information.scw_state_zone
  organization_id = var.state_infrastructure_information.scw_organization_id
  profile         = var.state_infrastructure_information.scw_profile
}
