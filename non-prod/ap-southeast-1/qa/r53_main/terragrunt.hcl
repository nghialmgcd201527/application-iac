locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Extract out common variables for reuse
  env            = local.environment_vars.locals.environment
  region         = local.region_vars.locals.aws_region
  web_app_domain = local.environment_vars.locals.datahouseasia_web_app_domain
}
// dependencies {
//   paths = ["../r53zone"]
// }
// dependency "r53zone" {
//   config_path = find_in_parent_folders("r53zone")
//   mock_outputs = {
//     zone_id = "temporary-url"
//   }
//   mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
// }
terraform {
  source = "${path_relative_from_include()}//modules/r53zone"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  domain      = local.web_app_domain
  environment = local.env
}

# dependencies {
#   paths = ["../terraform_aws_vpc_network"]
# }
