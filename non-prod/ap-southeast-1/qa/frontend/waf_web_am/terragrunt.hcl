locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Extract out common variables for reuse
  env        = local.environment_vars.locals.environment
  region     = local.region_vars.locals.aws_region
  web_domain = local.environment_vars.locals.web_am_domain
  web_bucket = local.environment_vars.locals.web_am_bucket

}

terraform {
  source = "${path_relative_from_include()}//modules/waf"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the nvariables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  bucket_name = "${local.web_bucket}-${local.env}"
}

# dependencies {
#   paths = ["../terraform_aws_vpc_network"]
# }
