env_name  = "staging"
region    = "us-west-2"
dr_region = "us-west-1"

aim_instance_type            = "r6a.xlarge"
aim_db_instance_type         = "db.m5.2xlarge"
aim_db_name                  = "aim"
aim_hostname                 = "aim-staging.assetworks.cloud.tamu.edu"
aim_db_password_op_item_uuid = "s5sjhwvhve63l5b42yrd2f6oiq"

ready_version       = "ready-13-2-release:latest"
ready_instance_type = "r6a.large"
ready_hostname      = "ready-staging.assetworks.cloud.tamu.edu"

op_vault = "None" 

use_acme      = false
acme_provider = "https://acme-v02.api.letsencrypt.org/directory"

in_maintenance_mode           = false
maintenance_mode_cname_value = "None"

force_destroy  = false
enable_backups = false


