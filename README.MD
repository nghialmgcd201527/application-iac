# BPP-MS Terraform

## Pre-requisites

1. Install [Terraform](https://www.terraform.io/) version `1.1.4` and
   [Terragrunt](https://github.com/gruntwork-io/terragrunt) version `v0.36.0` or newer
2. Configure our AWS credentials using one of the supported [authenticationmechanisms](https://www.terraform.io/docs/providers/aws/#authentication).
3. Fill in our AWS Account ID's in `{environment}/account.hcl`.

## Deploying a single module

1. `cd` into the module's folder (e.g. `cd non-prod/us-west-2/test/s3_web`).
2. Run `terragrunt plan` to see the changes we're about to apply.
3. If the plan looks good, run `terragrunt apply`.

## Deploying all modules in a region

1. `cd` into the environment folder (e.g. `non-prod/us-west-2/test`).
2. Run `terragrunt run-all plan` to see all the changes we're about to apply.
3. If the plan looks good, run `terragrunt run-all apply`.

# How is the code in this repo organized?

The code in this repo uses the following folder hierarchy:

```
environment-type
 ┣ region
 ┃ ┣ environment
 ┃ ┃ ┣ resource
 ┃ ┃ ┃ ┗ terragrunt.hcl -> define the Terragrunt configuration
 ┃ ┃ ┗ env.hcl  -> define environent information like name of environment and name of the S3 or domain
 ┃ ┗ region.hcl -> define region information
 ┗ account.hcl  -> define AWS account information : AWS Account ID, name..
```

Where:

- **environment-type**: At the top level are each of our environment that associated with a specific AWS accounts, such as `non-prod`,`prod` ... etc.
- **environment-name**: The environment name inside each of our environment-type that associated with the same AWS accounts, such as `dev`,`test` for `non-prod` ,`stg`,`prod` for `prod` ... etc.
- **Region**: Within each environment, there will be one or more [AWS regions](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html), such as
  `us-east-1`, `eu-west-1`, and `ap-southeast-2`, where we've deployed resources .

- **resource**: Within each environment, we deploy all the resources for that environment, such as s3-web,vpc, acm, route53 and so on.

# Organization level variables

In the situation where we have multiple AWS accounts ,we will create a specific `environment` and define it on "account.hcl"

```
locals {
  account_name   = "name-of-account"
  aws_account_id = "11111111111" # TODO: replace me with your AWS account
  aws_profile    = "name of aws_profile"
}
```
