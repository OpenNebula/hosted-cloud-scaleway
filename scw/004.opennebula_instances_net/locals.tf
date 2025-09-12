data "scaleway_account_project" "project" {
  name = var.project_fullname
}

locals {
  # From netplan_web.tf
  web_ipam_ip_ids = flatten([
    for net in tolist(data.terraform_remote_state.instances.outputs.opennebula_web_private_network) : net.ipam_ip_ids
  ])
  web_primary_ipam_ip_id = tolist(local.web_ipam_ip_ids)[0]
  web_vlan = tolist(data.terraform_remote_state.instances.outputs.opennebula_web_private_network)[0].vlan

  # From netplan.tf
  worker_ipam_ip_ids = flatten([
    for server_private_network in data.terraform_remote_state.instances.outputs.opennebula_worker_private_network :
    flatten([
      for net in tolist(server_private_network) : net.ipam_ip_ids
    ])
  ])
  worker_primary_ipam_ip_ids = [
    for server_private_network in data.terraform_remote_state.instances.outputs.opennebula_worker_private_network :
    tolist(flatten([
      for net in tolist(server_private_network) : net.ipam_ip_ids
    ]))[0]
  ]
  worker_address_cidrs = [
    for id in local.worker_primary_ipam_ip_ids :
    data.scaleway_ipam_ip.details[id].address_cidr
  ]
  worker_vlans = [
    for server_private_network in data.terraform_remote_state.instances.outputs.opennebula_worker_private_network :
    tolist(server_private_network)[0].vlan
  ]
}