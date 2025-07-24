
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
