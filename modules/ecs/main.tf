data "template_file" "ecs_task_execution_iam_role_policy_file" {
  template = file("${path.module}/policy/ecs-task-policy.json")
  vars = {
    account_id = var.account_id
  }
}

#################################################
# Create ECS Task Execution Role for ECS Service
#################################################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ECSTaskExecutionRole-Fargate"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Environment = var.stage
  }
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "ECS-Task-Execution-Policy"
  path        = "/"
  description = "Policy that attach to ecs task execution"
  policy      = data.template_file.ecs_task_execution_iam_role_policy_file.rendered
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_default_policy_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonCognitoPowerUser",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
  ])
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

#######################
# Create ECS Cluster
#######################

resource "aws_kms_key" "kms_cluster" {
  description             = "kms_ecs_cluster"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "kms_cluster" {
  name = "kms-ecs-cluster-log-group"
}

resource "aws_ecs_cluster" "fargate" {
  name = "${var.cluster_name}-${var.stage}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.kms_cluster.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.kms_cluster.name
      }
    }
  }
}

