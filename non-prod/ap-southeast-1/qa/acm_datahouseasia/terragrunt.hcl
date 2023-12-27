locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Extract out common variables for reuse
  env             = local.environment_vars.locals.environment
  region          = local.region_vars.locals.aws_region
  web_domain      = local.environment_vars.locals.dh_web_app_domain
  api_url         = local.environment_vars.locals.dh_api_url
  route53_zone_id = local.environment_vars.locals.dh_route53_zone_id
}

terraform {
  source = "${path_relative_from_include()}//modules/acm"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  domain_name                   = local.web_domain
  api_url                       = local.api_url
  zone_id                       = local.route53_zone_id
  subject_alternative_names     = ["*.${local.web_domain}"]
  api_subject_alternative_names = ["*.${local.api_url}"]
  wait_for_validation           = true
  environment                   = local.env
}

# dependencies {
#   paths = ["../terraform_aws_vpc_network"]
# }
