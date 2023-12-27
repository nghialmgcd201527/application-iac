# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name           = "terraform_admin"
  aws_account_id         = "565133770688" # TODO: replace me with your AWS account
  aws_profile            = "bizbone_qa"
  tooling_aws_account_id = "592463980955"
}
