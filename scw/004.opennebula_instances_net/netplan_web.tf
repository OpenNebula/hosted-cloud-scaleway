data "scaleway_ipam_ip" "web_details" {
  for_each    = toset(local.web_ipam_ip_ids)
  ipam_ip_id = each.key
}

resource "ssh_resource" "custom_cloud_init_script_web" {
  host  = data.terraform_remote_state.instances.outputs.public_ip_web
  user  = "ubuntu"

  private_key = data.terraform_remote_state.instances.outputs.private_ssh_pem
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
        base_public_ip                    = data.terraform_remote_state.instances.outputs.public_ip_web
        flexible_public_ip                = data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip
        gateway                           = cidrhost("${data.terraform_remote_state.instances.outputs.public_ip_web}/24", 1)
      }
    )
    destination = "/home/ubuntu/custom_cloud_init.sh"
    permissions = "0700"
  }

  commands = [
    "sudo bash /home/ubuntu/custom_cloud_init.sh && sudo netplan apply",
  ]
}

