
resource "random_password" "readysecret" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "readysecret" {
  name = "ready-${var.env_name}-readysecret"
}

resource "aws_secretsmanager_secret_version" "readysecret" {
  secret_id     = aws_secretsmanager_secret.readysecret.id
  secret_string = random_password.readysecret.result
}

resource "random_password" "aimsecret" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "aimsecret" {
  name = "aim-${var.env_name}-aimsecret"
}

resource "aws_secretsmanager_secret_version" "aimsecret" {
  secret_id     = aws_secretsmanager_secret.aimsecret.id
  secret_string = random_password.aimsecret.result
}

resource "aws_secretsmanager_secret" "db_pass" {
  name = "aim-${var.env_name}-db-pass"
}

resource "aws_secretsmanager_secret_version" "db_pass" {
  secret_id     = aws_secretsmanager_secret.db_pass.id
  secret_string = local.aim_db_password
}

resource "aws_ssm_parameter" "db_user" {
  name           = "/aim/${var.env_name}/db/user"
  description    = "The username for the AiM DB instance"
  type           = "String"
  insecure_value = aws_db_instance.aim.username
}

resource "aws_ssm_parameter" "db_host" {
  name           = "/aim/${var.env_name}/db/host"
  description    = "The hostname for the AiM DB instance"
  type           = "String"
  insecure_value = aws_db_instance.aim.address
}

resource "aws_ssm_parameter" "db_name" {
  name           = "/aim/${var.env_name}/db/name"
  description    = "The name of the database on the AiM DB instance"
  type           = "String"
  insecure_value = var.aim_db_name
}
