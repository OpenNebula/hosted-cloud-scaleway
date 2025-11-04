# # # ### Setup VPC Private-Network K8S Scaleway

# Private networks
resource "scaleway_vpc_private_network" "pn-vmtovm" {
  name = "subnet_private_vmtovm"
  vpc_id = scaleway_vpc.vpc.id 
  ipv4_subnet {
    subnet = var.vmtovm_subnet
  }
}


