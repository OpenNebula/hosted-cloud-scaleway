resource "ssh_resource" "ufw_web" {
  host        = data.terraform_remote_state.instances.outputs.public_ip_web
  user        = "ubuntu"
  private_key = data.terraform_remote_state.instances.outputs.private_ssh_pem

  commands = [
    "echo 'br_netfilter' | sudo tee /etc/modules-load.d/br_netfilter.conf",
    "sudo modprobe br_netfilter",
    "echo 'net.bridge.bridge-nf-call-iptables = 1' | sudo tee /etc/sysctl.d/99-bridge.conf",
    "sudo sysctl -p /etc/sysctl.d/99-bridge.conf",
    "sudo apt-get update && sudo apt-get install -y ufw",
    "sudo ufw --force reset",
    "sudo ufw default deny incoming",
    "sudo ufw default allow outgoing",
    format("sudo ufw allow from any to %s port 22 proto tcp", data.terraform_remote_state.instances.outputs.public_ip_web),
    format("sudo ufw allow from any to %s port 80 proto tcp", trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip, "/32")),
    format("sudo ufw allow from any to %s port 443 proto tcp", trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip, "/32")),
    format("sudo ufw allow from any to %s port 2474 proto tcp", trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip, "/32")),
    format("sudo ufw allow from any to %s port 5030 proto tcp", trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip, "/32")),
    format("sudo ufw allow from any to %s port 2102 proto tcp", trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip, "/32")),
    format("sudo ufw allow from any to %s port 2101 proto tcp", trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip, "/32")),
    format("sudo ufw allow from any to %s port 2616 proto tcp", trimsuffix(data.terraform_remote_state.instances.outputs.opennebula_web_flexible_ip, "/32")),
    "sudo ufw allow from 10.16.0.0/20",    "sudo ufw --force enable",
  ]
}

resource "ssh_resource" "ufw_workers" {
  count       = var.worker_count
  host        = data.terraform_remote_state.instances.outputs.public_ip_workers[count.index]
  user        = "ubuntu"
  private_key = data.terraform_remote_state.instances.outputs.private_ssh_pem

  commands = [
    "echo 'br_netfilter' | sudo tee /etc/modules-load.d/br_netfilter.conf",
    "sudo modprobe br_netfilter",
    "echo 'net.bridge.bridge-nf-call-iptables = 1' | sudo tee /etc/sysctl.d/99-bridge.conf",
    "sudo sysctl -p /etc/sysctl.d/99-bridge.conf",
    "sudo apt-get update && sudo apt-get install -y ufw",
    "sudo ufw --force reset",
    "sudo ufw default deny incoming",
    "sudo ufw default allow outgoing",
    format("sudo ufw allow from any to %s port 22 proto tcp", data.terraform_remote_state.instances.outputs.public_ip_workers[count.index]),
    "sudo ufw allow from 10.16.0.0/20",
    "sudo ufw allow 4789/udp",
    "sudo ufw allow out to 10.17.0.0/20",    "sudo ufw --force enable",
  ]
}
