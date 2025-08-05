variable "customer_name" {
  description = "Customer name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "state_infrastructure_information" {
  type = object({
    scw_infrastructure_project_name = string
  })
}

variable "tfstate" {
  type = string
}

variable "region" {
  type = string
}

variable "project_fullname" {
  type = string
}

