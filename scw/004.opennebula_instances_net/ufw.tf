resource "ssh_resource" "ufw_web" {
  host        = data.terraform_remote_state.instances.outputs.public_ip_web
  user        = "ubuntu"
  private_key = data.terraform_remote_state.instances.outputs.private_ssh_pem

  commands = [
    "sudo apt-get update && sudo apt-get install -y ufw",
    "sudo ufw --force reset",
    "sudo ufw default deny incoming",
    "sudo ufw default allow outgoing",
    format("sudo ufw allow from any to %s port 22 proto tcp", data.terraform_remote_state.instances.outputs.public_ip_web),
    format("sudo ufw allow from any to %s port 80 proto tcp", trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip, "/32")),
    format("sudo ufw allow from any to %s port 443 proto tcp", trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip, "/32")),
    "sudo ufw --force enable",
  ]
}

resource "ssh_resource" "ufw_workers" {
  count       = var.worker_count
  host        = data.terraform_remote_state.instances.outputs.public_ip_workers[count.index]
  user        = "ubuntu"
  private_key = data.terraform_remote_state.instances.outputs.private_ssh_pem

  commands = [
    "sudo apt-get update && sudo apt-get install -y ufw",
    "sudo ufw --force reset",
    "sudo ufw default deny incoming",
    "sudo ufw default allow outgoing",
    format("sudo ufw allow from any to %s port 22 proto tcp", data.terraform_remote_state.instances.outputs.public_ip_workers[count.index]),
    "sudo ufw --force enable",
  ]
}
