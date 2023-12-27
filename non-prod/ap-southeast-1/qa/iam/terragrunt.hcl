locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env                    = local.environment_vars.locals.environment
  region                 = local.region_vars.locals.aws_region
  tooling_aws_account_id = local.account_vars.locals.tooling_aws_account_id
  stage                  = local.environment_vars.locals.stage
}

terraform {
  source = "${path_relative_from_include()}//modules/iam"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  tooling_aws_account_id = local.tooling_aws_account_id
  stage                  = local.stage
}

# dependencies {
#   paths = ["../terraform_aws_vpc_network"]
# }
