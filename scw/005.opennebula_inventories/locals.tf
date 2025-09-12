data "scaleway_account_project" "project" {
  name = var.project_fullname
}

locals {
  cidr_bits = tonumber(regex("^.+/(\\d+)", data.terraform_remote_state.instances_net.outputs.private_netmask_web)[0])
  cidr_to_netmask = tomap({
    10 = "255.192.0.0"
    11 = "255.224.0.0"
    12 = "255.240.0.0"
    13 = "255.248.0.0"
    14 = "255.252.0.0"
    15 = "255.254.0.0"
    16 = "255.255.0.0"
    17 = "255.255.128.0"
    18 = "255.255.192.0"
    19 = "255.255.224.0"
    20 = "255.255.240.0"
    21 = "255.255.248.0"
    22 = "255.255.252.0"
    23 = "255.255.254.0"
    24 = "255.255.255.0"
    25 = "255.255.255.128"
    26 = "255.255.255.192"
    27 = "255.255.255.224"
    28 = "255.255.255.240"
  })

  frontend_netmask = local.cidr_to_netmask[local.cidr_bits]
  frontend_ip_public   = data.terraform_remote_state.instances.outputs.public_ip_web
  frontend_ip_flexible = data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip
  frontend_ip_private  = data.terraform_remote_state.instances_net.outputs.private_ip_web
  frontend_vlan        = data.terraform_remote_state.instances_net.outputs.vlan_web
  frontend_interface   = data.terraform_remote_state.instances_net.outputs.web_interface
  frontend_ip_cidr = "${local.frontend_ip_private}/${local.cidr_bits}"
  worker_ips = data.terraform_remote_state.instances.outputs.public_ip_workers
  private_worker_ips = data.terraform_remote_state.instances_net.outputs.private_ip_workers
}