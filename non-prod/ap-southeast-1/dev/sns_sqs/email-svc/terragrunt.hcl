locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Extract out common variables for reuse
  env          = local.environment_vars.locals.environment
  region       = local.region_vars.locals.aws_region
  project_name = local.environment_vars.locals.project_name
  service_name = local.environment_vars.locals.email_service_repo
  stage        = local.environment_vars.locals.stage
}

terraform {
  source = "${path_relative_from_include()}//modules/sns_sqs"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  project_name   = local.project_name
  service_name   = local.service_name
  stage          = local.stage
  is_sns_enabled = false
  is_encrypted   = true
}

# dependencies {
#   paths = ["../terraform_aws_vpc_network"]
# }
