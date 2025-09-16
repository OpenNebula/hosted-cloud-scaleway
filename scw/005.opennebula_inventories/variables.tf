
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
