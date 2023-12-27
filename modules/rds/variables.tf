variable "db_name" {
  type        = string
  description = "The name of the rds instance"
}

variable "service_name" {
  type        = string
  description = "The name of the rds instance"
}

variable "stage" {
  type        = string
  description = "Stage name"
}

variable "environment" {
  type        = string
  description = "The environment this RDS belongs to"
}

variable "private_subnet_ids" {
  type        = list(any)
  description = "The list of private subnet id"
}

variable "replicate_source_db" {
  type        = string
  description = "The source db of read replica instance"
  default     = null
}

variable "engine_version" {
  type        = string
  description = "The postgres engine version"
  default     = "15.4"
}

variable "instance_class" {
  type        = string
  description = "The instance type of the RDS instance"
  default     = "db.t3.small"
}

variable "username" {
  type        = string
  description = "Username for the master DB user"
  default     = "postgres"
}

variable "port" {
  type        = string
  description = "The port on which the DB accepts connections"
  default     = "5432"
}

variable "allocated_storage" {
  type        = string
  description = "The allocated storage in gigabytes. For read replica, set the same value as master's"
  default     = 20
}

variable "storage_type" {
  type        = string
  description = "One of standard (magnetic), gp2 (general purpose SSD), or io1 (provisioned IOPS SSD)"
  default     = "gp2"
}

variable "iops" {
  type        = string
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of io1"
  default     = "0"
}

variable "storage_encrypted" {
  type        = string
  description = "Specifies whether the DB instance is encrypted"
  default     = "true"
}

variable "kms_key_id" {
  type        = string
  description = "Specifies a custom KMS key to be used to encrypt"
  default     = ""
}

variable "vpc_security_group_ids" {
  type        = list(any)
  description = "VPC security groups to associate"
}

variable "db_subnet_group_name" {
  type        = string
  description = "Name of DB subnet group"
  default     = ""
}

variable "availability_zone" {
  type        = string
  description = "The AZ for the RDS instance. It is recommended to only use this when creating a read replica instance"
  default     = ""
}

variable "multi_az" {
  type        = string
  description = "Specifies if the RDS instance is multi-AZ"
  default     = "false"
}

variable "allow_major_version_upgrade" {
  type        = string
  description = "Indicates that major version upgrades are allowed"
  default     = "false"
}

variable "auto_minor_version_upgrade" {
  type        = string
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  default     = "false"
}

variable "apply_immediately" {
  type        = string
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  default     = "false"
}

variable "backup_retention_period" {
  type        = string
  description = "The days to retain backups for"
  default     = 7
}

variable "backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Before and not overlap with maintenance_window"
  default     = ""
}

variable "skip_final_snapshot" {
  type        = string
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
  default     = "true"
}

variable "copy_tags_to_snapshot" {
  type        = string
  description = "On delete, copy all Instance tags to the final snapshot (if final_snapshot_identifier is specified)"
  default     = "true"
}

variable "snapshot_identifier" {
  type        = string
  description = "The snapshot ID used to restore the DB instance"
  default     = ""
}

variable "monitoring_interval" {
  type        = string
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance"
  default     = "60"
}

variable "performance_insights_enabled" {
  type        = string
  description = "The values which defines if the performance insights for this db will be enabled or not"
  default     = "false"
}

variable "deletion_protection" {
  type        = string
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false"
  default     = true
}

variable "ca_cert_identifier" {
  type        = string
  description = "Specifies the identifier of the CA certificate for the DB instance"
  default     = "rds-ca-rsa2048-g1"
}

variable "additional_tags" {
  type        = map(string)
  default     = {}
  description = "The additional aws_db_instance tags that will be merged over the default tags"
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = []
  description = "List of log types to enable for exporting to CloudWatch logs"
}
