# # # ### Setup VPC Private-Network K8S Scaleway

# Private networks
resource "scaleway_vpc_private_network" "pn" {
  name = "subnet_private_opennebula"
  vpc_id = scaleway_vpc.vpc.id 
  ipv4_subnet {
    subnet = var.private_subnet
  }
}


