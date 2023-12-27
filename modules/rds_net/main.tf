# ######################################################################
# # Create Database Subnet Group then attach the private subnet into it
# ######################################################################

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${var.service_name}-${var.stage}-rds-dbsubnetgroup-net"
  subnet_ids = flatten([
    var.private_subnet_ids
  ])
}

########################
# Create RDS Database
########################
module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.service_name}-${var.stage}-db"

  engine             = "mysql"
  engine_version     = var.engine_version
  instance_class     = var.instance_class
  allocated_storage  = var.allocated_storage
  ca_cert_identifier = var.ca_cert_identifier

  db_name  = replace("${var.service_name}", "-", "_")
  username = "superadmin"
  password = "vizerpnetdev"
  port     = "3306"

  iam_database_authentication_enabled = false

  vpc_security_group_ids = var.vpc_security_group_ids

  maintenance_window = "mon:12:58-mon:13:28"
  backup_window      = "07:16-07:46"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole-${var.service_name}-net"
  create_monitoring_role = true

  tags = {
    Owner       = "superadmin"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids = flatten([
    var.private_subnet_ids
  ])

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = var.engine_version

  create_db_option_group = false
  parameter_group_name   = "${var.service_name}-${var.stage}-rds-dbparametergroup-net"

  # Database Deletion Protection
  deletion_protection = true
}
