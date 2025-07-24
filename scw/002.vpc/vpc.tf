# # ### Setup VPC Scaleway
resource "scaleway_vpc" "vpc" {
  project_id = data.scaleway_account_project.project.project_id 
  name = "vpc-${ var.project_fullname }"
  enable_routing = true 
}
