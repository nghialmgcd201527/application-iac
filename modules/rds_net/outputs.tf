output "address" {
  description = "The address of the RDS instance"
  value       = module.db.db_instance_address
}

output "arn" {
  description = "The ARN of the RDS instance"
  value       = module.db.db_instance_arn
}

output "endpoint" {
  description = "The connection endpoint"
  value       = module.db.db_instance_endpoint
}

output "hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = module.db.db_instance_hosted_zone_id
}

output "id" {
  description = "The RDS instance ID"
  value       = module.db.db_instance_identifier
}

output "resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = module.db.db_instance_resource_id
}

output "availability_zone" {
  description = "The availability zone of the instance"
  value       = module.db.db_instance_availability_zone
}

output "username" {
  description = "The username for the DB"
  value       = sensitive(module.db.db_instance_username)
  sensitive   = true
}

# output "db_url" {
#   description = "The postgre url"
#   value       = aws_ssm_parameter.db_url.value
#   sensitive   = true
# }
