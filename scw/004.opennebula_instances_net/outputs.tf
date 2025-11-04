output "private_ip_web" {
  value = data.scaleway_ipam_ip.web_details[local.web_primary_ipam_ip_id].address
}

output "private_ip_workers" {
  value = [
    for id in local.worker_primary_ipam_ip_ids :
    data.scaleway_ipam_ip.details[id].address
  ]
}

output "private_netmask_web" {
  value = data.scaleway_ipam_ip.web_details[local.web_primary_ipam_ip_id].address_cidr
}

output "vlan_web" {
  value = local.web_vlan
}

output "web_interface" {
  value = try(regex("Detected primary interface: (\\S+)", ssh_resource.custom_cloud_init_script_web.result)[0], null)
}

output "web_address_cidr" {
  value = data.scaleway_ipam_ip.web_details[local.web_primary_ipam_ip_id].address_cidr
}

output "stdout_web" {
  value = ssh_resource.custom_cloud_init_script_web.result
}

output "worker_interface_names" {
  value = [
    for res in ssh_resource.custom_cloud_init_script_workers :
    try(regex("Detected primary interface: (\\S+)", res.result)[0], null)
  ]
}

output "worker_address_cidrs" {
  value = local.worker_address_cidrs
}

output "stdout_worker" {
  value = [
    for res in ssh_resource.custom_cloud_init_script_workers :
    res.result
  ]
}

output "vmtovm_ip_web" {
  value = try(
    data.scaleway_ipam_ip.web_details[local.web_vmtovm_primary_ipam_ip_id].address,
    null
  )
}

output "vmtovm_ip_workers" {
  value = [
    for id in local.worker_vmtovm_primary_ipam_ip_ids :
    try(data.scaleway_ipam_ip.details[id].address, null)
  ]
}
