locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Extract out common variables for reuse
  env             = local.environment_vars.locals.environment
  region          = local.region_vars.locals.aws_region
  web_domain      = local.environment_vars.locals.asset_domain
  web_bucket      = local.environment_vars.locals.asset_bucket
  route53_zone_id = local.environment_vars.locals.route53_zone_id
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "${path_relative_from_include()}//modules/s3-staticweb"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}
dependency "acm" {
  config_path = find_in_parent_folders("acm")
  mock_outputs = {
    acm_certificate_arn = "arn:aws:acm:us-west-2:111111111111:certificate/random-id"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

dependency "waf_web_app" {
  config_path = find_in_parent_folders("waf_web_app")
  mock_outputs = {
    waf_arn = "arn:aws:wafv2:us-west-2:111111111111:scope/webacl/name/abcd1234-ab12-ab12-ab12-abcdef123456"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

dependencies {
  paths = ["../../acm", "../waf_web_app"]
}
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  region                       = local.region
  domain_name                  = local.web_domain
  bucket_name                  = "${local.web_bucket}-${local.env}"
  acm_certificate_arn          = dependency.acm.outputs.acm_certificate_arn
  not_found_response_path      = "/index.html"
  route53_zone_id              = local.route53_zone_id
  waf_acl_id                   = dependency.waf_web_app.outputs.waf_arn
  is_bucket_versioning_enabled = true
}
