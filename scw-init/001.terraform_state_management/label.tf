module "label_default" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.customer_name
  name        = var.project_name
  label_order = ["namespace", "stage", "name", "environment", "attributes"]

  delimiter = "-"

  tags = {
    customer_name    = var.customer_name,
    project_name     = var.project_name,
    scw_project_name = "${var.customer_name}-${var.project_name}-${local.scw_infrastructure_project_name}"

    cost_code        = "DEFAULT"
    environment      = "common"
    management       = "ManagedByTerraform"
  }
}
