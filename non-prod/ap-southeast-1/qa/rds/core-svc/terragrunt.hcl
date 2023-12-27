locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Extract out common variables for reuse
  env     = local.environment_vars.locals.environment
  region  = local.region_vars.locals.aws_region
  db_name = local.environment_vars.locals.db_name
  service_name  = local.environment_vars.locals.core_service_repo
  stage   = local.environment_vars.locals.stage
}

terraform {
  source = "${path_relative_from_include()}//modules/rds"
}

dependency "vpc" {

  config_path = find_in_parent_folders("vpc")
  mock_outputs = {
    vpc_id                   = "vpc-abcd1234abcd123"
    private_subnet_ids       = ["subnet-0a98713c3e9f2d7e8", "subnet-0918274c16074ffdb"]
    db_security_group_id     = ["sg-00cd718d0d754e668"]
    database_security_groups = ["sg-00cd718d0d754e668"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}
dependencies {
  paths = ["../../vpc"]
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  db_name                = local.db_name
  service_name           = local.service_name
  stage                  = local.stage
  vpc_security_group_ids = dependency.vpc.outputs.database_security_groups
  private_subnet_ids     = dependency.vpc.outputs.datacenter_subnet_ids
}
