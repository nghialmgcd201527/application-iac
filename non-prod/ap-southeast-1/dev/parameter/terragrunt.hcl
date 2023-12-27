locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env          = local.environment_vars.locals.environment
  region       = local.region_vars.locals.aws_region
  stage        = local.environment_vars.locals.stage
  account_id   = local.account_vars.locals.aws_account_id
  project_name = local.environment_vars.locals.project_name
  api_url      = local.environment_vars.locals.api_url
}

terraform {
  source = "${path_relative_from_include()}//modules/parameter_store"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the nvariables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  stage              = local.stage
  environment        = local.env
  region             = local.region
  account_id         = local.account_id
  timezone           = "Pacific/Honolulu"
  project_name       = local.project_name
  api_url            = local.api_url
  tooling_account_id = "665959705335"
}

# dependencies {
#   paths = ["../terraform_aws_vpc_network"]
# }
