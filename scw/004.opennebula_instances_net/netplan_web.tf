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
      "${path.module}/template/cloud_init_custom.tmpl",
      {
        baremetal_server_ipam_address     = data.scaleway_ipam_ip.web_details[local.web_primary_ipam_ip_id].address_cidr
        private_network_vlan_assignment   = local.web_vlan
        private_network_cidr              = data.scaleway_ipam_ip.web_details[local.web_primary_ipam_ip_id].address_cidr
        base_public_ip                    = data.terraform_remote_state.instances.outputs.public_ip_web
        flexible_public_ip                = data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip
        gateway                           = cidrhost("${data.terraform_remote_state.instances.outputs.public_ip_web}/24", 1),
        is_web_server                     = true
      }
    )
    destination = "/home/ubuntu/custom_cloud_init.sh"
    permissions = "0700"
  }

  commands = [
    "sudo bash /home/ubuntu/custom_cloud_init.sh && sudo netplan apply",
  ]
}

#resource "ssh_resource" "vnm_pre_hook_web" {
#  depends_on = [ssh_resource.custom_cloud_init_script_web]

#  host  = data.terraform_remote_state.instances.outputs.public_ip_web
#  user  = "ubuntu"

#  private_key = data.terraform_remote_state.instances.outputs.private_ssh_pem
#  timeout     = "2m"
#  when        = "create"

#  commands = [
#    "sudo mkdir -p /var/lib/one/remotes/vnm/bridge/pre.d/",
#    <<-CMD
#      sudo tee /var/lib/one/remotes/vnm/bridge/pre.d/01-routes-web.sh > /dev/null <<'EOF'
#      ${templatefile("${path.module}/templates/vnm_pre_hook_web.sh.tmpl", { flexible_public_ip = trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip, "/32"), gateway_ip = cidrhost("${data.terraform_remote_state.instances.outputs.public_ip_web}/24", 1) })}
#      EOF
#    CMD
#    ,
#    "sudo chmod +x /var/lib/one/remotes/vnm/bridge/pre.d/01-routes-web.sh"
#  ]
#}

#resource "ssh_resource" "vnm_clean_hook_web" {
#  depends_on = [ssh_resource.custom_cloud_init_script_web]

#  host  = data.terraform_remote_state.instances.outputs.public_ip_web
#  user  = "ubuntu"

#  private_key = data.terraform_remote_state.instances.outputs.private_ssh_pem
#  timeout     = "2m"
#  when        = "create"

#  commands = [
#    "sudo mkdir -p /var/lib/one/remotes/vnm/bridge/clean.d/",
#    <<-CMD
#      sudo tee /var/lib/one/remotes/vnm/bridge/clean.d/01-routes-web.sh > /dev/null <<'EOF'
#      ${templatefile("${path.module}/templates/vnm_clean_hook_web.sh.tmpl", { flexible_public_ip = trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip, "/32"), gateway_ip = cidrhost("${data.terraform_remote_state.instances.outputs.public_ip_web}/24", 1) })}
#      EOF
#    CMD
#    ,
#    "sudo chmod +x /var/lib/one/remotes/vnm/bridge/clean.d/01-routes-web.sh"
#  ]
#}

