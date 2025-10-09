resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.yml.tmpl", {
    frontend_ip_public       = local.frontend_ip_public,
    frontend_ip_flexible     = local.frontend_ip_flexible,
    frontend_ip_flexible_mac = local.frontend_ip_flexible_mac,
    frontend_gateway         = local.frontend_gateway,
    frontend_ip_private      = local.frontend_ip_private,
    frontend_netmask         = local.frontend_netmask,
    frontend_vlan            = local.frontend_vlan,
    frontend_ip_cidr         = local.frontend_ip_cidr,
    worker_ips               = local.worker_ips,
    private_worker_ips       = local.private_worker_ips,
    frontend_interface_priv  = "${local.frontend_interface}",
    frontend_interface_pub   = local.frontend_interface,
    one_password             = var.one_password,
    scw_secret_key           = var.scw_secret_key,
    private_network_id       = local.private_network_id,
    region                   = var.region
  })

  filename        = "${path.module}/generated/inventory.yml"
  file_permission = "0644"
}

resource "local_file" "ipam_script" {
  content = templatefile("${path.module}/templates/ipam_scaleway.py.tmpl", {})
  filename = "${path.module}/generated/ipam_scaleway.py"
  file_permission = "0755"
}



