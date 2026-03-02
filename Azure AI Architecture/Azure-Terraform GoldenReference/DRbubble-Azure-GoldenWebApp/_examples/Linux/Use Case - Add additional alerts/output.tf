output "app_service_plan_id" {
  value       = module.GoldenLinuxWebApp.app_service_plan_id
  description = "App service plan Id created within the module"
  sensitive   = false
}
output "action_group_id" {
  value       = module.GoldenLinuxWebApp.action_group_id
  description = "Action group Id created within the module"
  sensitive   = false
}