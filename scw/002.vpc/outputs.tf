output "private_network_id" {
  description = "The ID of the VPC Private Network."
  value       = scaleway_vpc_private_network.pn.id
}
