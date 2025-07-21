
module "terraform_state_backend" {

  source  = "scaleway-terraform-modules/bucket/scaleway"
  version = "0.5.0"

  project_id         = scaleway_account_project.scw_infrastructure_project.id
  force_destroy      = true
  name               = var.state_infrastructure_information.scw_state_bucket
  versioning_enabled = true

  versioning_lock_configuration = {
    "days" : null, "mode" : "GOVERNANCE", "years" : 1
  }

  tags = distinct(tolist(values(merge(
    module.label_default.tags,
    {
      CostCode        = "INFRASTRUCTURE/STATE_MANAGEMENT",
      TerraformStates = "terraform-states-infra"
  }))))
}
