data "scaleway_ipam_ip" "details" {
  for_each    = toset(local.worker_ipam_ip_ids)
  ipam_ip_id = each.key
}

resource "ssh_resource" "custom_cloud_init_script_workers" {
  count       = var.worker_count
  host        = data.terraform_remote_state.instances.outputs.public_ip_workers[count.index]
  user        = "ubuntu"
  private_key = data.terraform_remote_state.instances.outputs.private_ssh_pem

  timeout     = "20s"
  retry_delay = "5s"
  when        = "create"

  file {
    content = templatefile(
      "${path.module}/template/cloud_init_custom.tmpl",
      {
        baremetal_server_ipam_address     = data.scaleway_ipam_ip.details[local.worker_primary_ipam_ip_ids[count.index]].address_cidr
        private_network_vlan_assignment   = local.worker_vlans[count.index]
        private_network_cidr              = data.scaleway_ipam_ip.details[local.worker_primary_ipam_ip_ids[count.index]].address_cidr
        base_public_ip                    = data.terraform_remote_state.instances.outputs.public_ip_workers[count.index]
        flexible_public_ip                = data.terraform_remote_state.instances.outputs.opennebula_worker_flexible_ip[count.index]
        gateway                           = cidrhost("${data.terraform_remote_state.instances.outputs.public_ip_workers[count.index]}/24", 1),
        is_web_server                     = false
      }
    )
    destination = "/home/ubuntu/custom_cloud_init.sh"
    permissions = "0700"
  }
  commands = [
    "sudo bash /home/ubuntu/custom_cloud_init.sh && sudo netplan apply",
  ]
}

#resource "ssh_resource" "vnm_pre_hook_worker" {
#  count = var.worker_count
#  depends_on = [ssh_resource.custom_cloud_init_script_workers]

#  host  = data.terraform_remote_state.instances.outputs.public_ip_workers[count.index]
#  user  = "ubuntu"

#  private_key = data.terraform_remote_state.instances.outputs.private_ssh_pem
#  timeout     = "2m"
#  when        = "create"

#  commands = [
#    "sudo mkdir -p /var/lib/one/remotes/vnm/bridge/pre.d/",
#    <<-CMD
#      sudo tee /var/lib/one/remotes/vnm/bridge/pre.d/02-routes-worker-${count.index}.sh > /dev/null <<'EOF'
#      ${templatefile("${path.module}/templates/vnm_pre_hook_worker.sh.tmpl", { flexible_public_ip = trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_worker_flexible_ip[count.index], "/32"), gateway_ip = cidrhost("${data.terraform_remote_state.instances.outputs.public_ip_workers[count.index]}/24", 1) })}
#      EOF
#    CMD
#    ,
#    "sudo chmod +x /var/lib/one/remotes/vnm/bridge/pre.d/02-routes-worker-${count.index}.sh"
#  ]
#}

#resource "ssh_resource" "vnm_clean_hook_worker" {
#  count = var.worker_count
#  depends_on = [ssh_resource.custom_cloud_init_script_workers]
# 
#  host  = data.terraform_remote_state.instances.outputs.public_ip_workers[count.index]
#  user  = "ubuntu"

#  private_key = data.terraform_remote_state.instances.outputs.private_ssh_pem
#  timeout     = "2m"
#  when        = "create"

#  commands = [
#    "sudo mkdir -p /var/lib/one/remotes/vnm/bridge/clean.d/",
#    <<-CMD
#      sudo tee /var/lib/one/remotes/vnm/bridge/clean.d/02-routes-worker-${count.index}.sh > /dev/null <<'EOF'
#      ${templatefile("${path.module}/templates/vnm_clean_hook_worker.sh.tmpl", { flexible_public_ip = trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_worker_flexible_ip[count.index], "/32"), gateway_ip = cidrhost("${data.terraform_remote_state.instances.outputs.public_ip_workers[count.index]}/24", 1) })}
#      EOF
#    CMD
#    ,
#    "sudo chmod +x /var/lib/one/remotes/vnm/bridge/clean.d/02-routes-worker-${count.index}.sh"
#  ]
#}
