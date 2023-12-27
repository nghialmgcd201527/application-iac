locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env                = local.environment_vars.locals.environment
  region             = local.region_vars.locals.aws_region
  stage              = local.environment_vars.locals.stage
  availability_zones = ["${local.region_vars.locals.aws_region}a", "${local.region_vars.locals.aws_region}b"]
  account_id         = local.account_vars.locals.aws_account_id
}
dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
  mock_outputs = {
    vpc_id = "vpc-abcd1234abcd123"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}


dependencies {
  paths = ["../vpc", ]
}

terraform {
  source = "${path_relative_from_include()}//modules/ecs"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  stage              = local.stage
  vpc_id             = dependency.vpc.outputs.vpc_id
  availability_zones = local.availability_zones
  cluster_name       = "bizbone-cluster"
  account_id         = local.account_id
}

# dependencies {
#   paths = ["../terraform_aws_vpc_network"]
# }
