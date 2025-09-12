output "private_ip_web" {
  value = [
    for ip in data.scaleway_ipam_ip.web_details :
    ip.address
    if !can(regex(":", ip.address))
  ][0]
}

output "private_ip_workers" {
  value = [
    for ip in data.scaleway_ipam_ip.details :
    ip.address
    if !can(regex(":", ip.address))  # exclut les IPv6
  ]
}

output "private_netmask_web" {
  value = [
    for ip in data.scaleway_ipam_ip.web_details :
    ip.address_cidr
    if !can(regex(":", ip.address))
  ][0]
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
