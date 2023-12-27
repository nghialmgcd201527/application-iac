############################################################
# Create ECR Repository for service
############################################################

resource "aws_ecr_repository" "main" {
  name                 = "${var.repo_name}-${var.stage}"
  image_tag_mutability = var.image_tag_mutability

  # Image scanning configuration
  image_scanning_configuration {
    scan_on_push = var.is_scan_on_push
  }


  tags = {
    Name        = "${var.repo_name}-ecr-${var.stage}"
    Environment = "var.environment"
  }
}

############################################################
# Create Target Group for service
############################################################

#BLUE TARGET GROUP
resource "aws_lb_target_group" "target_group_be" {
  name        = "${var.repo_name}-${var.stage}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    path                = "/${var.short_name}/health"
    protocol            = "HTTP"
    port                = var.container_port
    timeout             = "5"
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
  }
  vpc_id = var.vpc_id
}
#GREEN TARGET GROUP
resource "aws_lb_target_group" "target_group_green" {
  name        = "${var.repo_name}-${var.stage}-tg-green"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    path                = "/${var.short_name}/health"
    protocol            = "HTTP"
    port                = var.container_port
    timeout             = "5"
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
  }
  vpc_id = var.vpc_id
}

############################################################
# Task Definition
############################################################
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-${var.repo_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  skip_destroy             = true
  container_definitions = jsonencode([
    {
      name   = "${var.project_name}-${var.repo_name}"
      image  = "${aws_ecr_repository.main.repository_url}:${var.stage}"
      cpu    = 1024
      memory = 512
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  tags = {
    Name        = "${var.repo_name}-task-${var.stage}"
    Environment = var.environment
  }
}


resource "aws_lb_listener_rule" "service_rule" {
  listener_arn = var.https_listener_arn
  priority     = var.routing_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_be.arn
  }
  condition {
    path_pattern {
      values = ["/${var.short_name}", "/${var.short_name}/", "/${var.short_name}/*"]
    }
  }
}

resource "random_password" "api_key" {
  special = false
  length  = 32
}

#Parameter for service
resource "aws_ssm_parameter" "api_port" {
  name  = "/${var.repo_name}/${var.stage}/API_PORT"
  type  = "String"
  value = var.container_port

  tags = {
    environment = var.stage
  }
}
resource "aws_ssm_parameter" "api_key" {
  name  = "/${var.repo_name}/${var.stage}/API_KEY"
  type  = "String"
  value = random_password.api_key.result

  tags = {
    environment = var.stage
  }
}


resource "aws_ecs_service" "api_service" {
  name                    = "${var.project_name}-${var.repo_name}"
  cluster                 = var.ecs_id
  task_definition         = aws_ecs_task_definition.main.arn
  enable_ecs_managed_tags = true
  launch_type             = "FARGATE"
  desired_count           = var.min_tasks
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_be.arn
    container_name   = "${var.project_name}-${var.repo_name}"
    container_port   = var.container_port
  }
  network_configuration {
    subnets = flatten([
      var.private_subnets
    ])

    security_groups = flatten([
      var.private_security
    ])
  }
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}

# Code Deploy

resource "aws_codedeploy_app" "main" {
  compute_platform = "ECS"
  name             = "${var.repo_name}-${var.stage}-application"
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name               = aws_codedeploy_app.main.name
  deployment_group_name  = "${var.repo_name}-${var.stage}-deploygroup"
  deployment_config_name = var.deployment_config_name
  service_role_arn       = "arn:aws:iam::${var.aws_account_id}:role/CodeDeploy_ECS_Role"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = aws_ecs_service.api_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.https_listener_arn]
      }
      target_group {
        name = aws_lb_target_group.target_group_be.name
      }
      target_group {
        name = aws_lb_target_group.target_group_green.name
      }
    }
  }
}
resource "aws_s3_bucket" "codepipeline" {
  bucket = "${var.repo_name}-${var.stage}-pipeline-artifact-fixed"
}

resource "aws_s3_bucket" "artifact_store" {
  bucket = "${var.project_name}-${var.repo_name}-${var.stage}-artifact-ecs"
}
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowGetPutDeleteObjects"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:role/Cross-Account-Code-Build-Role"]
    }
    actions = [
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:GetObjectAcl",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
    ]
    resources = ["arn:aws:s3:::${var.project_name}-${var.repo_name}-${var.stage}-artifact-ecs/*"]
  }

  statement {
    sid    = "AllowListBucket"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:role/Cross-Account-Code-Build-Role"]
    }
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.project_name}-${var.repo_name}-${var.stage}-artifact-ecs"]
  }
}

resource "aws_s3_bucket_policy" "artifact_store" {
  bucket = aws_s3_bucket.artifact_store.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_s3_bucket_versioning" "versioning_artifact_store" {
  bucket = aws_s3_bucket.artifact_store.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_codepipeline" "this" {
  name     = "${var.repo_name}-${var.stage}-pipeline"
  role_arn = "arn:aws:iam::${var.aws_account_id}:role/CodePipeline_CodeDeploy_role"

  artifact_store {
    location = aws_s3_bucket.codepipeline.bucket
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      name     = "S3Source"
      category = "Source"
      owner    = "AWS"
      configuration = {
        PollForSourceChanges = "false"
        S3Bucket             = aws_s3_bucket.artifact_store.id
        S3ObjectKey          = "appspec.zip"
      }
      provider = "S3"
      version  = "1"
      output_artifacts = [
        "appspecartifact"
      ]
      run_order = 1
    }
  }
  stage {
    name = "Deploy"
    action {
      name     = "Deploy"
      category = "Deploy"
      owner    = "AWS"
      configuration = {
        AppSpecTemplateArtifact        = "appspecartifact"
        AppSpecTemplatePath            = "appspec.yml"
        ApplicationName                = "${var.repo_name}-${var.stage}-application"
        DeploymentGroupName            = "${var.repo_name}-${var.stage}-deploygroup"
        Image1ArtifactName             = "appspecartifact"
        Image1ContainerName            = "IMAGE1_NAME"
        TaskDefinitionTemplateArtifact = "appspecartifact"
        TaskDefinitionTemplatePath     = "taskdef.json"
      }
      input_artifacts = [
        "appspecartifact"
      ]
      provider  = "CodeDeployToECS"
      version   = "1"
      run_order = 1
    }
  }
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarm CPU High
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "ecs-${var.repo_name}-${var.stage}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Maximum"
  threshold           = var.alarm_ecs_high_cpu_threshold
  alarm_description   = "Cluster CPU above threshold"
  # alarm_actions             = var.alarm_sns_topics
  # ok_actions                = var.alarm_sns_topics
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.api_service.name
  }
  alarm_actions = [aws_appautoscaling_policy.scale_up_policy.arn]
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarm CPU Low
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "ecs-${var.repo_name}-${var.stage}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = var.alarm_ecs_low_cpu_threshold
  alarm_description   = "Cluster CPU below threshold"
  # alarm_actions             = var.alarm_sns_topics
  # ok_actions                = var.alarm_sns_topics
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.api_service.name
  }
  alarm_actions = [aws_appautoscaling_policy.scale_down_policy.arn]
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Up Policy
#------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "scale_up_policy" {
  name               = "${var.repo_name}-${var.stage}-scale-up-policy"
  depends_on         = [aws_appautoscaling_target.scale_target]
  service_namespace  = aws_appautoscaling_target.scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.scale_target.scalable_dimension
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Down Policy
#------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "scale_down_policy" {
  name               = "${var.repo_name}-${var.stage}-scale-down-policy"
  depends_on         = [aws_appautoscaling_target.scale_target]
  service_namespace  = aws_appautoscaling_target.scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.scale_target.scalable_dimension
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Target
#------------------------------------------------------------------------------
resource "aws_appautoscaling_target" "scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.api_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_tasks
  max_capacity       = var.max_tasks
}

resource "aws_cloudwatch_log_group" "main" {
  name = "${var.project_name}-${var.repo_name}"
}
