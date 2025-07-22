output "terraform_state_backend_module" {
  value = module.terraform_state_backend
}

output "scw_infrastructure_project" {
  value = scaleway_account_project.scw_infrastructure_project
}
