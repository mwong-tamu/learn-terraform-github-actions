locals {
  aim_db_password = "Aggies2023!" #var.aim_db_password_op_item_uuid != null ? data.onepassword_item.copy_aim_db_password[0].password : (var.aim_db_password != null ? var.aim_db_password : random_password.aim_db.result)
}

resource "aws_db_subnet_group" "aim_db" {
  name       = "aim-${var.env_name}-rds-subnet-group"
  subnet_ids = [data.aws_subnet.private_1.id,data.aws_subnet.private_2.id]
}

resource "aws_db_option_group" "aim_db" {
  name                     = "aim-${var.env_name}-rds-option-group"
  option_group_description = "Option group for the ${var.env_name} AIM RDS instance"
  engine_name              = "sqlserver-se"
  major_engine_version     = "15.00"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = aws_iam_role.rds_backuprestore.arn
    }
  }
}

resource "aws_db_parameter_group" "aim_db" {
  name        = "aim-${var.env_name}-rds-param-group"
  family      = "sqlserver-se-15.0"
  description = "Database parameter group for ${var.env_name} AIM RDS instance"

  parameter {
    name  = "cost threshold for parallelism"
    value = "5"
  }
}

resource "random_password" "aim_db" {
  length  = 16
  special = false
}


resource "aws_security_group" "rds" {
  name_prefix = "aim-${var.env_name}-rds-"
  description = "AIM RDS security group for ${var.env_name}"
  vpc_id      = data.aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 1433
    to_port   = 1434
    protocol  = "tcp"
    # cidr_blocks     = var.rds_ingress.cidr_blocks
    cidr_blocks = ["0.0.0.0/0"]
    # prefix_list_ids = ["pl-01baada8612ac4fef"] # TAMU Networks
    # security_groups = [
    #   aws_security_group.aim.id
    # ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name               = "aim-${var.env_name}-rds-enhanced-monitoring"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_db_instance" "aim" {
  identifier                            = "aim-${var.env_name}-rds"
  allocated_storage                     = 100
  max_allocated_storage                 = 100 * 10
  multi_az                              = false
  allow_major_version_upgrade           = false
  option_group_name                     = aws_db_option_group.aim_db.name
  engine                                = "sqlserver-se"
  engine_version                        = "15.00.4316.3.v1"
  instance_class                        = var.aim_db_instance_type
  username                              = "admin"
  password                              = local.aim_db_password
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  publicly_accessible                   = false
  snapshot_identifier                   = var.aim_db_snapshot_identifier
  skip_final_snapshot                   = true
  storage_type                          = "gp2"
  license_model                         = "license-included"
  db_subnet_group_name                  = aws_db_subnet_group.aim_db.name
  deletion_protection                   = var.force_destroy ? false : true
  apply_immediately                     = true
  maintenance_window                    = "Sun:06:00-Sun:07:00"
  backup_window                         = "08:00-09:00"
  backup_retention_period               = var.enable_backups ? 28 : 0
  timezone                              = "Central Standard Time"
  parameter_group_name                  = aws_db_parameter_group.aim_db.name

  enabled_cloudwatch_logs_exports = [
    "agent",
    "error",
  ]

  # Enhanced monitoring
  # monitoring_interval = 60
  # monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  lifecycle {
    ignore_changes = [timezone]
  }
}

resource "aws_iam_role" "rds_backuprestore" {
  name               = "aim-${var.env_name}-rds-backuprestore-role"
  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "rds.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
      ]
    }
  EOF

  inline_policy {
    name   = "rds-backup-restore"
    policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
              "s3:ListBucket",
              "s3:GetBucketLocation"
          ],
          "Resource": [
              "arn:aws:s3:::${aws_s3_bucket.rds_operations.bucket}"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
              "s3:GetObjectMetaData",
              "s3:GetObject",
              "s3:PutObject",
              "s3:ListMultipartUploadParts",
              "s3:AbortMultipartUpload"
          ],
          "Resource": [
              "arn:aws:s3:::${aws_s3_bucket.rds_operations.bucket}/rds/*"
          ]
        }
      ]
    }
    EOF
  }
}

resource "aws_db_instance_automated_backups_replication" "default" {
  count = var.enable_backups ? 1 : 0

  source_db_instance_arn = aws_db_instance.aim.arn
  retention_period       = 14

  provider = aws.dr

  timeouts {
    create = "60m"
  }
}
