resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.yml.tmpl", {
    frontend_ip_public   = local.frontend_ip_public
    frontend_ip_private  = local.frontend_ip_private
    frontend_netmask     = local.frontend_netmask
    frontend_vlan        = local.frontend_vlan
    frontend_ip_cidr     = local.frontend_ip_cidr
    worker_ips           = local.worker_ips
    frontend_interaface_priv= "eth0.${local.frontend_vlan}@${local.frontend_interface}"
    frontend_interaface_pub    = local.frontend_interface 
  })

  filename = "${path.module}/generated/inventory.yml"
}

