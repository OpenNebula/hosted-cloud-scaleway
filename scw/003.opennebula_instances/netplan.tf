locals {
  worker_ipam_ip_ids = flatten([
    for server in scaleway_baremetal_server.opennebula-worker :
    flatten([
      for net in tolist(server.private_network) : net.ipam_ip_ids
    ])
  ])

  worker_primary_ipam_ip_ids = [
    for server in scaleway_baremetal_server.opennebula-worker :
    tolist(flatten([
      for net in tolist(server.private_network) : net.ipam_ip_ids
    ]))[0]
  ]

  worker_address_cidrs = [
    for id in local.worker_primary_ipam_ip_ids :
    data.scaleway_ipam_ip.details[id].address_cidr
  ]

  worker_vlans = [
    for server in scaleway_baremetal_server.opennebula-worker :
    tolist(server.private_network)[0].vlan
  ]
}

data "scaleway_ipam_ip" "details" {
  for_each    = toset(local.worker_ipam_ip_ids)
  ipam_ip_id = each.key
}

resource "ssh_resource" "custom_cloud_init_script_workers" {
  count       = var.worker_count
  host        = scaleway_baremetal_server.opennebula-worker[count.index].ipv4[0].address
  user        = "ubuntu"
  private_key = tls_private_key.ssh.private_key_pem

  timeout     = "10m"
  retry_delay = "5s"
  when        = "create"

  file {
    content = templatefile(
      "template/cloud_init_custom.tmpl",
      {
        baremetal_server_ipam_address     = data.scaleway_ipam_ip.details[local.worker_primary_ipam_ip_ids[count.index]].address_cidr
        private_network_vlan_assignment   = local.worker_vlans[count.index]
        private_network_cidr              = data.scaleway_ipam_ip.details[local.worker_primary_ipam_ip_ids[count.index]].address_cidr
        baremetal_server_interface_name   = "eth0"
      }
    )
    destination = "/home/ubuntu/custom_cloud_init.sh"
    permissions = "0700"
  }
  commands = [
    "bash /home/ubuntu/custom_cloud_init.sh",
    "iface=$(cat /tmp/interface_name.txt) && echo \"{\\\"interface\\\": \\\"$iface\\\"}\""
  ]
}

output "worker_interface_names" {
  value = [
    for res in ssh_resource.custom_cloud_init_script_workers :
    try(jsondecode(res.result).interface, null)
  ]
}

output "worker_address_cidrs" {
  value = local.worker_address_cidrs
}
