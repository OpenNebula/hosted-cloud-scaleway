locals {
  flexible_ip_name = "opennebula-flexip-${var.project_fullname}"
}

resource "scaleway_iam_application" "opennebula_flexible_ip" {
  name        = local.flexible_ip_name
  description = "IAM application for OpenNebula Flexible IP driver"
  tags        = ["opennebula", "flexible-ip"]
}

resource "scaleway_iam_group" "opennebula_flexible_ip" {
  name        = "${local.flexible_ip_name}-group"
  description = "IAM group granting access to Flexible IPs"
  tags        = ["opennebula", "flexible-ip"]
  application_ids = [
    scaleway_iam_application.opennebula_flexible_ip.id,
  ]
}

resource "scaleway_iam_policy" "opennebula_flexible_ip_admin" {
  name        = "${local.flexible_ip_name}-policy"
  description = "Allow Flexible IP administration for the OpenNebula driver"
  group_id    = scaleway_iam_group.opennebula_flexible_ip.id

  rule {
    project_ids = [data.scaleway_account_project.project.id]
    permission_set_names = var.flexible_ip_permission_sets
  }
}

resource "scaleway_iam_api_key" "opennebula_flexible_ip" {
  application_id     = scaleway_iam_application.opennebula_flexible_ip.id
  description        = "OpenNebula Flexible IP driver API key"
  default_project_id = data.scaleway_account_project.project.id

  depends_on = [
    scaleway_iam_policy.opennebula_flexible_ip_admin
  ]
}
