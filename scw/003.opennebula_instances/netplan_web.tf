locals {
  web_ipam_ip_ids = flatten([
    for net in tolist(scaleway_baremetal_server.opennebula-web.private_network) : net.ipam_ip_ids
  ])

  web_primary_ipam_ip_id = tolist(local.web_ipam_ip_ids)[0]

  web_vlan = tolist(scaleway_baremetal_server.opennebula-web.private_network)[0].vlan
}

data "scaleway_ipam_ip" "web_details" {
  for_each    = toset(local.web_ipam_ip_ids)
  ipam_ip_id = each.key
}

resource "ssh_resource" "custom_cloud_init_script_web" {
  host  = scaleway_baremetal_server.opennebula-web.ipv4[0].address
  user  = "ubuntu"

  private_key = tls_private_key.ssh.private_key_pem
  timeout     = "10m"
  retry_delay = "5s"
  when        = "create"

  file {
    content = templatefile(
      "template/cloud_init_custom.tmpl",
      {
        baremetal_server_ipam_address     = data.scaleway_ipam_ip.web_details[local.web_primary_ipam_ip_id].address_cidr
        private_network_vlan_assignment   = local.web_vlan
        private_network_cidr              = data.scaleway_ipam_ip.web_details[local.web_primary_ipam_ip_id].address_cidr
        baremetal_server_interface_name   = "eth0"
      }
    )
    destination = "/home/ubuntu/custom_cloud_init.sh"
    permissions = "0700"
  }

  commands = [
    "bash /home/ubuntu/custom_cloud_init.sh",
    "iface=$(cat /tmp/interface_name.txt) && echo '{\"interface\":\"'$iface'\"}'"
  ]
}

output "web_interface" {
  value = try(jsondecode(ssh_resource.custom_cloud_init_script_web.result).interface, null)
}

output "web_address_cidr" {
  value = data.scaleway_ipam_ip.web_details[local.web_primary_ipam_ip_id].address_cidr
}

