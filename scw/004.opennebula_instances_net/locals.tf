data "scaleway_account_project" "project" {
  name = var.project_fullname
}

locals {
  vmtovm_private_network_id = data.terraform_remote_state.vpc.outputs.vmtovm_private_network_id

  web_private_networks = tolist(data.terraform_remote_state.instances.outputs.opennebula_web_private_network)
  web_primary_candidates = [
    for net in local.web_private_networks :
    net if try(net.id, null) != local.vmtovm_private_network_id
  ]
  web_primary_private_network = try(
    local.web_primary_candidates[0],
    local.web_private_networks[0]
  )
  web_vmtovm_candidates = [
    for net in local.web_private_networks :
    net if try(net.id, null) == local.vmtovm_private_network_id
  ]
  web_vmtovm_private_network = try(local.web_vmtovm_candidates[0], null)
  web_ipam_ip_ids = flatten([
    for net in local.web_private_networks : tolist(net.ipam_ip_ids)
  ])
  web_primary_ipam_ip_id = tolist(local.web_primary_private_network.ipam_ip_ids)[0]
  web_vmtovm_primary_ipam_ip_id = try(tolist(local.web_vmtovm_private_network.ipam_ip_ids)[0], null)
  web_vlan = local.web_primary_private_network.vlan
  web_vmtovm_vlan = try(local.web_vmtovm_private_network.vlan, null)

  worker_private_network_groups = [
    for server_private_network in data.terraform_remote_state.instances.outputs.opennebula_worker_private_network :
    tolist(server_private_network)
  ]
  worker_primary_networks = [
    for group in local.worker_private_network_groups :
    try(
      [
        for net in group :
        net if try(net.id, null) != local.vmtovm_private_network_id
      ][0],
      group[0]
    )
  ]
  worker_vmtovm_networks = [
    for group in local.worker_private_network_groups :
    try(
      [
        for net in group :
        net if try(net.id, null) == local.vmtovm_private_network_id
      ][0],
      null
    )
  ]
  worker_ipam_ip_ids = flatten([
    for group in local.worker_private_network_groups :
    flatten([
      for net in group : tolist(net.ipam_ip_ids)
    ])
  ])
  worker_primary_ipam_ip_ids = [
    for net in local.worker_primary_networks :
    tolist(net.ipam_ip_ids)[0]
  ]
  worker_vmtovm_primary_ipam_ip_ids = [
    for net in local.worker_vmtovm_networks :
    try(tolist(net.ipam_ip_ids)[0], null)
  ]
  worker_vlans = [
    for net in local.worker_primary_networks :
    net.vlan
  ]
  worker_vmtovm_vlans = [
    for net in local.worker_vmtovm_networks :
    try(net.vlan, null)
  ]
  worker_address_cidrs = [
    for id in local.worker_primary_ipam_ip_ids :
    data.scaleway_ipam_ip.details[id].address_cidr
  ]
}
