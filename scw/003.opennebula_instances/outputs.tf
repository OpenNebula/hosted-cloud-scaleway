locals {
  ipam_ids = flatten([for net in scaleway_baremetal_server.opennebula-web.private_network : net.ipam_ip_ids ])
}

output "private_ssh_pem" {
  sensitive = true
  value = tls_private_key.ssh.private_key_pem
}

output "public_ip_web" {
  value = scaleway_baremetal_server.opennebula-web.ipv4[0].address
}

output "public_ip_workers" {
  value = [for s in scaleway_baremetal_server.opennebula-worker : s.ipv4[0].address]
}

output "opennebula_web_server_id" {
  value = scaleway_baremetal_server.opennebula-web.id
}

output "opennebula_worker_server_ids" {
  value = [for s in scaleway_baremetal_server.opennebula-worker : s.id]
}

output "opennebula_web_private_network" {
  value = scaleway_baremetal_server.opennebula-web.private_network
}

output "opennebula_worker_private_network" {
    value = [for s in scaleway_baremetal_server.opennebula-worker : s.private_network]
}

output "opennebula_worker_flexible_ip" {
  value = [for ip in scaleway_flexible_ip.opennebula-worker-public-ip : ip.ip_address]
}

output "opennebula_worker_flexible_ip_mac" {
  value = [for mac in scaleway_flexible_ip_mac_address.opennebula-worker-public-ip-mac : mac.address ]
}

output "opennebula_web_flexible_ip" {
  value = scaleway_flexible_ip.opennebula-web-public-ip
}

output "opennebula_web_flexible_ip_mac" {
  value = scaleway_flexible_ip_mac_address.opennebula-web-public-ip-mac.address
}
