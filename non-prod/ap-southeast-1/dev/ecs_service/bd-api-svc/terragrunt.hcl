locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  project_name   = local.environment_vars.locals.project_name
  env            = local.environment_vars.locals.environment
  region         = local.region_vars.locals.aws_region
  repo_name      = local.environment_vars.locals.bd_api_repo
  stage          = local.environment_vars.locals.stage
  container_port = local.environment_vars.locals.bd_service_port
  short_name     = local.environment_vars.locals.bd_api_repo_short_name
  aws_account_id = local.account_vars.locals.aws_account_id
}

terraform {
  source = "${path_relative_from_include()}//modules/backend_service"
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
  mock_outputs = {
    vpc_id                   = "vpc-abcd1234abcd123"
    database_security_groups = ["sg-00cd718d0d754e668"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

dependency "ecs_cluster" {
  config_path = find_in_parent_folders("ecs_cluster")
  mock_outputs = {
    ecs_task_execution_role_arn = "arn:aws:iam::111111111111:role/Name-ECSTaskExecutionRole-ABCD123456"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

dependency "alb" {
  config_path = find_in_parent_folders("alb")
  mock_outputs = {
    https_listener_arn = "arn:aws:elasticloadbalancing:us-west-2:111111111111:listener/app/bpp-ms-api-elb/92c970793514ef35/f514456ec9131776"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}


dependencies {
  paths = ["../../vpc", "../../ecs_cluster", "../../alb"]
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  project_name                = local.project_name
  repo_name                   = local.repo_name
  short_name                  = local.short_name
  stage                       = local.stage
  container_port              = local.container_port
  vpc_id                      = dependency.vpc.outputs.vpc_id
  container_cpu               = 1024
  container_memory            = 2048
  ecs_task_execution_role_arn = dependency.ecs_cluster.outputs.ecs_task_execution_role_arn
  ecs_id                      = dependency.ecs_cluster.outputs.ecs_cluster_id
  ecs_cluster_name            = "bizbone-cluster-dev"
  environment                 = local.env
  routing_priority            = 5
  https_listener_arn          = dependency.alb.outputs.https_listener_arn
  private_security            = dependency.vpc.outputs.private_security_groups
  private_subnets             = dependency.vpc.outputs.private_subnet_ids
  min_tasks                   = 1
  max_tasks                   = 3
  deployment_config_name      = "CodeDeployDefault.ECSAllAtOnce"
  aws_account_id              = local.aws_account_id
}
