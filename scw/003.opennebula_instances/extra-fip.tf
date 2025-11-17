resource "scaleway_flexible_ip" "opennebula-extra-public-ip" {
  zone = var.zone
  description = "opennebula-extra-public-ip"
   lifecycle {
     ignore_changes = [
        is_ipv6,
        server_id
     ]
  }
}

resource "scaleway_flexible_ip_mac_address" "opennebula-extra-public-ip-mac" {
  flexible_ip_id = scaleway_flexible_ip.opennebula-extra-public-ip.id
  type           = "kvm"
}
