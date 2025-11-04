output "private_network_id" {
  description = "The ID of the VPC Private Network."
  value       = scaleway_vpc_private_network.pn.id
}

output "vmtovm_private_network_id" {
  description = "The ID of the VM-to-VM private network."
  value       = scaleway_vpc_private_network.pn-vmtovm.id
}
