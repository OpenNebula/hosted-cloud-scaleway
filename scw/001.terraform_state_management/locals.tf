locals {
  scw_infrastructure_project_name = "${var.customer_name}-${var.project_name}-${var.state_infrastructure_information.scw_infrastructure_project_name}"
  scw_state_bucket = "${local.scw_infrastructure_project_name}-tfstates"
}
