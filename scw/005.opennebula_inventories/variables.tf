
variable "tfstate" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "project_fullname" {
  type = string
}

variable "private_subnet" {
  type = string
}

variable "worker_count" {
  type = number
  default = 1
}

variable "one_password" {
  type        = string
  description = "Password for the OpenNebula oneadmin user."
  sensitive   = true
}

variable "scw_secret_key" {
  type        = string
  description = "Scaleway API Secret Key."
  sensitive   = true
}

variable "flexible_ip_dns" {
  type        = list(string)
  description = "DNS resolvers advertised by the Scaleway Flexible IP driver."
  default     = ["1.1.1.1"]
}

variable "flexible_ip_permission_sets" {
  type        = list(string)
  description = "Permission sets attached to the IAM policy used by the Flexible IP driver (see Scaleway IAM documentation)."
  default     = ["ElasticMetalFullAccess", "IPAMFullAccess"]
}

variable "flexible_ip_gateway" {
  type        = string
  description = "Gateway for Scaleway Flexible IP driver."
  default     = "62.210.0.1"
}
