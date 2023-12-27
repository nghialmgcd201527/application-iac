locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env             = local.environment_vars.locals.environment
  region          = local.region_vars.locals.aws_region
  web_domain      = local.environment_vars.locals.web_ac_domain
  web_bucket      = local.environment_vars.locals.web_ac_bucket
  route53_zone_id = local.environment_vars.locals.route53_zone_id
  aws_account_id  = local.account_vars.locals.aws_account_id
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

dependency "waf_web" {
  config_path = find_in_parent_folders("waf_web_ac")
  mock_outputs = {
    waf_arn = "arn:aws:wafv2:us-west-2:111111111111:scope/webacl/name/abcd1234-ab12-ab12-ab12-abcdef123456"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

dependencies {
  paths = ["../../acm", "../waf_web_ac"]
}
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  region                  = local.region
  domain_name             = local.web_domain
  bucket_name             = "${local.web_bucket}-${local.env}"
  acm_certificate_arn     = "arn:aws:acm:us-east-1:756955845548:certificate/31c88de1-2ee9-414d-ba90-ce7913c71ce0"
  not_found_response_path = "/index.html"
  route53_zone_id         = local.route53_zone_id
  waf_acl_id              = dependency.waf_web.outputs.waf_arn
  aws_account_id          = local.aws_account_id
}
