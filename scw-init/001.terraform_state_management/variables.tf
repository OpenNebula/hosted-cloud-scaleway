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
    scw_profile                     = string
    scw_state_bucket                = string
    scw_state_region                = string
    scw_state_zone                  = string
    scw_organization_id             = string
    scw_infrastructure_project_name = string
  })
}
