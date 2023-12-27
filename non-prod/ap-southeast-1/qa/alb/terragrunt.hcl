locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Extract out common variables for reuse
  env                = local.environment_vars.locals.environment
  region             = local.region_vars.locals.aws_region
  stage              = local.environment_vars.locals.stage
  api_url            = local.environment_vars.locals.dh_api_url
  project_name       = local.environment_vars.locals.project_name
  route53_zone_id    = local.environment_vars.locals.dh_route53_zone_id
  availability_zones = ["${local.region_vars.locals.aws_region}a", "${local.region_vars.locals.aws_region}b"]
  ssl_policy_name    = local.environment_vars.locals.ssl_policy_name
  api_gw_ids         = local.environment_vars.locals.api_gw_ids
}

terraform {
  source = "${path_relative_from_include()}//modules/alb"
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
  mock_outputs = {
    vpc_id                 = "vpc-abcd1234abcd123"
    public_subnet_ids      = ["subnet-0a98713c3e9f2d7e8", "subnet-0918274c16074ffdb"]
    public_security_groups = ["sg-00cd718d0d754e668"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}
dependency "acm" {
  config_path = find_in_parent_folders("acm_datahouseasia")
  mock_outputs = {
    api_acm_certificate_arn = "arn:aws:acm:us-west-2:111111111111:certificate/random-id"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}


dependencies {
  paths = ["../vpc", "../acm_datahouseasia"]
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  project_name            = local.project_name
  stage                   = local.stage
  vpc_id                  = dependency.vpc.outputs.vpc_id
  route53_zone_id         = local.route53_zone_id
  api_url                 = local.api_url
  environment             = local.env
  security_groups         = dependency.vpc.outputs.alb_security_groups
  availability_zones      = local.availability_zones
  public_subnet_ids       = dependency.vpc.outputs.public_subnet_ids
  wait_for_validation     = true
  environment             = local.env
  ssl_policy_name         = local.ssl_policy_name
  api_acm_certificate_arn = dependency.acm.outputs.api_acm_certificate_arn
  acm_certificate_arn     = dependency.acm.outputs.acm_certificate_arn
  api_gw_ids              = local.api_gw_ids
}
