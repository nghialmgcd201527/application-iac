# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  #change to vizerp for prod
  project_name = "bizbone"
  environment  = "qa"
  asset_domain = "asset.qa.erp.datahouse.vn"
  web_app_domain      = "qa.erp.datahouse.vn"
  // web_app_domain      = ["qa.erp.datahouse.vn","qa.vizerp.vn"]
  dh_web_app_domain = "qa.vizerp.vn"
  web_admin_domain    = ["admin.qa.vizerp.vn","dh.qa.vizerp.vn"]
  web_identity_domain = ["identity.qa.erp.datahouse.vn","identity.qa.vizerp.vn"]
  dh_web_identity_domain = "identity.qa.vizerp.vn"
  api_url             = "api.qa.erp.datahouse.vn"
  dh_api_url  = "api.qa.vizerp.vn"
  core_api_url        = ["api.qa.vizerp.vn"]
  web_app_domain_tenant      = "bizbone.qa.erp.datahouse.vn"
  dh_web_app_domain_tenant = "dh.qa.vizerp.vn"
  // serverless_api_url          = "serverless.qa.erp.datahouse.vn"
  api_service_repo = "api-service"

  // Human Resources repo
  hr_api_repo = "hr-service"
  hr_api_repo_short_name     = "hr-svc"
  web_hr_domain    = "hr.bizbone.qa.erp.datahouse.vn"
  dh_web_hr_domain    = "hr.dh.qa.vizerp.vn"
  web_hr_bucket    = "bizbone-web-hr"

  // Recruitment Management repo
  rm_api_repo = "rm-service"
  rm_api_repo_short_name     = "rm-svc"
  web_rm_domain    = "rm.bizbone.qa.erp.datahouse.vn"
  dh_web_rm_domain    = "rm.dh.qa.vizerp.vn"
  web_rm_bucket    = "bizbone-web-rm"

  // // Contract Management repo
  // cm_api_repo = "cm-service"
  // cm_api_repo_short_name     = "cm-svc"
  // web_cm_domain    = "cm.qa.erp.datahouse.vn"
  // web_cm_bucket    = "bizbone-web-cm"

  // // Business Development repo
  // bd_api_repo = "bd-service"
  // bd_api_repo_short_name     = "bd-svc"
  // web_bd_domain    = "bd.qa.erp.datahouse.vn"
  // web_bd_bucket    = "bizbone-web-bd"

  // Administration Management repo
  am_api_repo = "am-service"
  am_api_repo_short_name     = "am-svc"
  web_am_domain    = "am.bizbone.qa.erp.datahouse.vn"
  dh_web_am_domain    = "am.dh.qa.vizerp.vn"
  web_am_bucket    = "bizbone-web-am"

  // // Information Technology repo
  // it_api_repo = "it-service"
  // it_api_repo_short_name     = "it-svc"
  // web_it_domain    = "it.qa.erp.datahouse.vn"
  // web_it_bucket    = "bizbone-web-it"

  // Timekeeping repo
  tk_api_repo = "tk-service"
  tk_api_repo_short_name     = "tk-svc"
  web_tk_domain    = "tk.bizbone.qa.erp.datahouse.vn"
  dh_web_tk_domain    = "tk.dh.qa.vizerp.vn"
  web_tk_bucket    = "bizbone-web-tk"

  // Accounting repo
  ac_api_repo = "ac-service"
  ac_api_repo_short_name     = "ac-svc"
  web_ac_domain    = "ac.bizbone.qa.erp.datahouse.vn"
  dh_web_ac_domain    = "ac.dh.qa.vizerp.vn"
  web_ac_bucket    = "vizerp-web-ac"

  // Payroll repo
  pr_api_repo = "pr-service"
  pr_api_repo_short_name     = "pr-svc"
  web_pr_domain    = "pr.bizbone.qa.erp.datahouse.vn"
  dh_web_pr_domain   = "pr.dh.qa.vizerp.vn"
  web_pr_bucket    = "bizbone-web-pr"

  #new
  web_app_bucket      = "bizbone-web-app"
  web_admin_bucket    = "bizbone-web-admin"
  web_identity_bucket = "bizbone-web-identity"
  asset_bucket        = "bizbone-asset"
  user_storage_bucket = "bizbone-user-storage-bucket"

  vpc_cidr                = "10.130.0.0/20"
  public_subnets_cidr     = ["10.130.1.0/24", "10.130.2.0/24"]
  private_subnets_cidr    = ["10.130.3.0/24", "10.130.4.0/24"]
  datacenter_subnets_cidr = ["10.130.5.0/24", "10.130.6.0/24"]
  thirdparty_subnets_cidr = ["10.130.7.0/24", "10.130.8.0/24"]
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
  
  db_name                    = "erp_db"
  api_gw_ids           = [{"id": "726g802ycf", "path": "locale-svc", stage: "qa"},{"id": "gytzz2p2y1", "path": "appointment-svc", stage: "qa"},{"id": "siwuuh1hy1", "path": "notification-svc", stage: "qa"}]

  hr_service_port     = 5000
  rm_service_port     = 5002
  cm_service_port     = 5003
  bd_service_port     = 5004
  am_service_port     = 5005
  it_service_port     = 5006
  tk_service_port     = 5007
  ac_service_port     = 5008
  pr_service_port     = 5009

  core_service_port = 5001

  stage           = "qa"
  route53_zone_id = "Z0986684JWTVVKVU39SD"
  route5_zone_ids = ["Z0935495PMZ5UID8DG7A"]
  dh_route53_zone_id = "Z0935495PMZ5UID8DG7A"
  ssl_policy_name = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  
  // Add more repo if create
  // repo_name_list = ["core-service","tk-service","am-service","hr-service","rm-service"]
  repo_name_list = ["pr-service"]
}
