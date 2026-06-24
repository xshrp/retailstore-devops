output "service_names" {
  description = "ECS service names"
  value       = keys(var.services)
}