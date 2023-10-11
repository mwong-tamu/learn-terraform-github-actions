variable "env_name" {}
variable "region" {}
variable "dr_region" {
  description = "Region to replicate backups to"
}

variable "aim_instance_type" {
  default = "m6a.xlarge"
}

variable "aim_hostname" {}

variable "aim_db_instance_type" {
  default = "db.m5.xlarge"
}

variable "aim_db_name" {
  default = "aim"
}

variable "aim_db_password" {
  description = "Password for the AIM database. One of this or aim_db_password_op_item_uuid required if restoring from snapshot."
  type        = string
  default     = null
}

variable "aim_db_password_op_item_uuid" {
  description = "1Password item UUID for the AIM database. One of this or aim_db_password required if restoring from snapshot."
  type        = string
  default     = null
}

variable "aim_db_snapshot_identifier" {
  description = "value of the snapshot identifier to restore from"
  default     = null
  type        = string
}

variable "ready_instance_type" {
  default = "m6a.large"
}

variable "ready_version" {
  default = "ready-13-3-release:latest"
}

variable "ready_hostname" {}

variable "op_vault" {}

variable "ansible_check" {
  default = false
  type    = bool
}

variable "op_item_uuid_aim_tls" {
  description = "The 1Password item UUID for the TLS certificate for AIM"
  default     = null
}
variable "op_item_uuid_ready_tls" {
  description = "The 1Password item UUID for the TLS certificate for ReADY"
  default     = null
}

variable "use_acme" {
  description = "Use ACME protocol TLS certificates"
  default     = false
  type        = bool
}

variable "acme_provider" {
  description = "ACME provider for TLS certificates"
  default     = "https://acme-staging-v02.api.letsencrypt.org/directory"
  type        = string
}

variable "in_maintenance_mode" {
  default = false
  type    = bool
}

variable "maintenance_mode_cname_value" {
  description = "CNAME value to use for ReADY during maintenance mode"
}

variable "notification_emails" {
  description = "List of email addresses to notify"
  type        = list(string)
  default     = []
}

variable "enable_backups" {
  description = "Enable backups for this environment"
  default     = true
  type        = bool
}

variable "force_destroy" {
  description = "Force destroy of resources"
  default     = false
  type        = bool
}

variable "ingress_ip" {
  description = "IP range in CIDR notation to allow ingress from for provisioning"
  default     = ""
  type        = string
}

variable "write_keypair_to_file" {
  description = "Write the keypair to a file"
  default     = false
  type        = bool
}
