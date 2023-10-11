# data "terraform_remote_state" "shared_resources" {
#   backend   = "s3"
#   workspace = "default"
#   config = {
#     bucket = "account-tfstate-${data.aws_caller_identity.current.account_id}"
#     key    = "account-tfstate/shared-resources.tfstate"
#     region = "us-west-2"

#   }
# }

# data "aws_s3_bucket" "assetworks_media" {
#   bucket = data.terraform_remote_state.shared_resources.outputs.media_s3_bucket
# }

resource "aws_s3_bucket" "rds_operations" {
  bucket        = "aim-${var.env_name}-rds-operations"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket" "backups" {
  bucket              = "assetworks-${var.env_name}-backups"
  object_lock_enabled = true
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "backups" {
  bucket = aws_s3_bucket.backups.bucket
  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 14
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.bucket
  rule {
    id = "delete-old-backups"
    filter {
      prefix = "backups/"
    }
    status = "Enabled"
    expiration {
      days = 30
    }
  }
}
