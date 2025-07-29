locals {
  ipam_ids = flatten([for net in scaleway_baremetal_server.opennebula-web.private_network : net.ipam_ip_ids ])
}

output "private_ssh_pem" {
  sensitive = true
  value = tls_private_key.ssh.private_key_pem
}

output "private_ip_web" {
  value = data.scaleway_ipam_ip.web_details[local.web_primary_ipam_ip_id].address
}

output "private_ip_workers" {
  value = [
    for ip in data.scaleway_ipam_ip.details :
    ip.address
    if !can(regex(":", ip.address))  # exclut les IPv6
  ]
}

output "public_ip_web" {
  value = scaleway_baremetal_server.opennebula-web.ipv4[0].address
}

output "public_ip_workers" {
  value = [for s in scaleway_baremetal_server.opennebula-worker : s.ipv4[0].address]
}

output "private_netmask_web" {
  value = data.scaleway_ipam_ip.web_details[local.web_primary_ipam_ip_id].address_cidr
}

output "vlan_web" {
  value = local.web_vlan
}
