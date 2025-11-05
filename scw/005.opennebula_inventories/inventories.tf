resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.yml.tmpl", {
    frontend_ip_public       = local.frontend_ip_public,
    frontend_ip_flexible     = local.frontend_ip_flexible,
    frontend_ip_flexible_mac = local.frontend_ip_flexible_mac,
    frontend_gateway         = local.frontend_gateway,
    flexible_ip_gateway      = var.flexible_ip_gateway,
    frontend_ip_private      = local.frontend_ip_private,
    frontend_ip_vmtovm       = local.frontend_ip_vmtovm,
    frontend_netmask         = local.frontend_netmask,
    frontend_vlan            = local.frontend_vlan,
    frontend_ip_cidr         = local.frontend_ip_cidr,
    worker_ips               = local.worker_ips,
    private_worker_ips       = local.private_worker_ips,
    worker_vmtovm_ips        = local.worker_vmtovm_ips,
    frontend_interface_priv  = "${local.frontend_interface}",
    frontend_interface_pub   = local.frontend_interface,
    one_password             = var.one_password,
    scw_secret_key           = var.scw_secret_key,
    private_network_id       = local.private_network_id,
    region                   = var.region,
    zone                     = var.zone,
    flexible_ip_token        = scaleway_iam_api_key.opennebula_flexible_ip.secret_key,
    flexible_ip_dns          = jsonencode(var.flexible_ip_dns),
    frontend_server_id       = local.frontend_id,
    worker_server_ids        = local.worker_ids,
    project_id               = data.scaleway_account_project.project.id
  })

  filename        = "${path.module}/generated/inventory.yml"
  file_permission = "0644"
}
