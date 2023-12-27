# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  #change to vizerp for prod
  project_name = "bizbone"
  environment  = "dev"
  asset_domain = "asset.dev.erp.datahouse.vn"

  web_app_domain      = "dev.erp.datahouse.vn"
  web_admin_domain    = "admin.dev.erp.datahouse.vn"
  web_identity_domain = "identity.dev.erp.datahouse.vn"
  api_url             = "api.dev.erp.datahouse.vn"
  serverless_api_url          = "serverless.dev.erp.datahouse.vn"

  // Human Resources repo
  hr_api_repo = "hr-service"
  hr_api_repo_short_name     = "hr-svc"
  web_hr_domain    = "hr.dev.erp.datahouse.vn"
  web_hr_bucket    = "bizbone-web-hr"

  // Recruitment Management repo
  rm_api_repo = "rm-service"
  rm_api_repo_short_name     = "rm-svc"
  web_rm_domain    = "rm.dev.erp.datahouse.vn"
  web_rm_bucket    = "bizbone-web-rm"

  // Contract Management repo
  cm_api_repo = "cm-service"
  cm_api_repo_short_name     = "cm-svc"
  web_cm_domain    = "cm.dev.erp.datahouse.vn"
  web_cm_bucket    = "bizbone-web-cm"

  // Business Development repo
  bd_api_repo = "bd-service"
  bd_api_repo_short_name     = "bd-svc"
  web_bd_domain    = "bd.dev.erp.datahouse.vn"
  web_bd_bucket    = "bizbone-web-bd"

  // Administration Management repo
  am_api_repo = "am-service"
  am_api_repo_short_name     = "am-svc"
  web_am_domain    = "am.dev.erp.datahouse.vn"
  web_am_bucket    = "bizbone-web-am"

  // Information Technology repo
  it_api_repo = "it-service"
  it_api_repo_short_name     = "it-svc"
  web_it_domain    = "it.dev.erp.datahouse.vn"
  web_it_bucket    = "bizbone-web-it"

  // Timekeeping repo
  tk_api_repo = "tk-service"
  tk_api_repo_short_name     = "tk-svc"
  web_tk_domain    = "tk.bizbone.dev.erp.datahouse.vn"
  web_tk_bucket    = "bizbone-web-tk"

  // Accounting repo
  ac_api_repo = "ac-service"
  ac_api_repo_short_name     = "ac-svc"
  web_ac_domain    = "ac.bizbone.dev.erp.datahouse.vn"
  web_ac_bucket    = "bizbone-web-ac"

  // Payroll repo
  pr_api_repo = "pr-service"
  pr_api_repo_short_name     = "pr-svc"
  web_pr_domain    = "pr.bizbone.dev.erp.datahouse.vn"
  web_pr_bucket    = "bizbone-web-pr"

  // Program Management
  pm_api_repo = "pm-service"
  pm_api_repo_short_name     = "pm-svc"
  web_pm_domain    = "pm.bizbone.dev.erp.datahouse.vn"
  web_pm_bucket    = "bizbone-web-pm"

  // Storage
  storage_repo = "storage-service"
  
  // Request Management
  rq_api_repo = "rq-service"
  rq_api_repo_short_name     = "rq-svc"
  web_rq_domain    = "rq.bizbone.dev.erp.datahouse.vn"
  web_rq_bucket    = "bizbone-web-rq"

  // Researching A LOI NGUEN
  researching_api_repo = "rresearching-service"
  researching_api_repo_short_name     = "researching-svc"
  web_researching_domain    = "mf.bizbone.dev.erp.datahouse.vn"
  web_researching_bucket    = "bizbone-web-researching"

  #new
  web_app_bucket      = "bizbone-web-app"
  web_admin_bucket    = "bizbone-web-admin"
  web_identity_bucket = "bizbone-web-identity"
  asset_bucket        = "bizbone-asset"
  user_storage_bucket = "bizbone-user-storage-bucket"

  vpc_cidr                = "10.110.0.0/20"
  public_subnets_cidr     = ["10.110.1.0/24", "10.110.2.0/24"]
  private_subnets_cidr    = ["10.110.3.0/24", "10.110.4.0/24"]
  datacenter_subnets_cidr = ["10.110.5.0/24", "10.110.6.0/24"]
  thirdparty_subnets_cidr = ["10.110.7.0/24", "10.110.8.0/24"]
  // public_subnets_cidr        = ["10.110.0.0/24", "10.110.1.0/24"]
  // private_subnets_cidr       = ["10.110.10.0/24", "10.110.11.0/24"]
  // datacenter_subnets_cidr    = ["10.110.12.0/26", "10.110.12.64/26"]
  // thirdparty_subnets_cidr    = ["10.110.13.0/26", "10.110.13.64/26"]
  account_service_repo       = "account-service"
  core_service_repo         = "core-service"
  email_service_repo         = "email-service"
  core_service_short_name    = "core-svc"
  locale_service_repo        = "locale-service"
  storage_service_repo       = "store-service"

  api_gw_ids           = [{"id": "726g802ycf", "path": "locale-svc", stage: "dev"},{"id": "gytzz2p2y1", "path": "appointment-svc", stage: "dev"},{"id": "siwuuh1hy1", "path": "notification-svc", stage: "dev"}]

  hr_service_port     = 5000
  rm_service_port     = 5002
  cm_service_port     = 5003
  bd_service_port     = 5004
  am_service_port     = 5005
  it_service_port     = 5006
  tk_service_port     = 5007
  ac_service_port     = 5008
  pr_service_port     = 5009
  pm_service_port     = 5010
  rq_service_port     = 5011

  core_service_port = 5001
  


  stage           = "dev"
  route53_zone_id = "Z06210182JQLBORR98NRO"
  ssl_policy_name = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}
