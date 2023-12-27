resource "aws_ssm_parameter" "timezone" {
  name  = "/global/APP_TIME_ZONE"
  type  = "String"
  value = var.timezone

  tags = {
    environment = var.stage
  }
}

resource "aws_ssm_parameter" "bd_app_name" {
  name  = "/global/${var.stage}/BD_APP_NAME"
  type  = "String"
  value = "BD"

  tags = {
    environment = var.stage
  }
}

resource "aws_ssm_parameter" "core_app_name" {
  name  = "/global/${var.stage}/CORE_APP_NAME"
  type  = "String"
  value = "CORE"

  tags = {
    environment = var.stage
  }
}

resource "aws_ssm_parameter" "api_url" {
  name  = "/global/${var.stage}/API_URL"
  type  = "String"
  value = var.api_url

  tags = {
    environment = var.stage
  }
}
resource "random_password" "api_key" {
  special = false
  length  = 32
}
resource "aws_ssm_parameter" "api_key" {
  name  = "/global/${var.stage}/API_KEY"
  type  = "String"
  value = random_password.api_key.result

  tags = {
    environment = var.stage
  }
}

resource "random_password" "jwt_key" {
  special = false
  length  = 64
}
resource "aws_ssm_parameter" "jwt_key" {
  name  = "/global/${var.stage}/JWT_SECRET"
  type  = "String"
  value = random_password.jwt_key.result

  tags = {
    environment = var.stage
  }
}

#####UPDATE#####
resource "aws_ssm_parameter" "core_service_name" {
  name  = "/global/${var.stage}/CORE_SERVICE_APP_NAME "
  type  = "String"
  value = "Core API"

  tags = {
    environment = var.stage
  }
}

resource "aws_ssm_parameter" "bd_service_name" {
  name  = "/global/${var.stage}/BD_SERVICE_APP_NAME "
  type  = "String"
  value = "BD service"

  tags = {
    environment = var.stage
  }
}

resource "aws_ssm_parameter" "global_stage" {
  name  = "/global/${var.stage}/STAGE "
  type  = "String"
  value = var.stage

  tags = {
    environment = var.stage
  }
}


resource "aws_ssm_parameter" "db_url" {
  for_each = { for repo, repo_name in var.repo_name_list : repo => repo_name }
  name     = "/${each.value}/${var.stage}/DATABASE_URL"
  type     = "String"
  value    = var.db_url_sensitive
  tags = {
    environment = var.stage
  }
}

resource "aws_ssm_parameter" "api_service_name" {
  name  = "/global/${var.stage}/API_SERVICE_APP_NAME "
  type  = "String"
  value = "api"
  tags = {
    environment = var.stage
  }
}
