variable "tfstate" {
  type = string
}

variable "region" {
  type = string
}

variable "project_fullname" {
  type = string
}

variable "worker_count" {
  type = number
  default = 1
}