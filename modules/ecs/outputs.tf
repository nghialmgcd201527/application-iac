output "ecs_cluster_id" {
  value       = aws_ecs_cluster.fargate.id
  description = "ECS Cluster ID"
}

output "ecs_cluster_arn" {
  value       = aws_ecs_cluster.fargate.arn
  description = "ECS Cluster ARN"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.fargate.name
  description = "ECS Cluster ARN"
}

output "ecs_task_execution_role_arn" {
  value       = aws_iam_role.ecs_task_execution_role.arn
  description = "ECS Task Execution Role ARN"
}

