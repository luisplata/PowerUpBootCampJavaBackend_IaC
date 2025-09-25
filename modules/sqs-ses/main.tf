resource "aws_sqs_queue" "mail_queue" {
  name                      = "${var.name_prefix}-mail-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400 # 1 día
  tags                       = var.tags
}

# SES Domain Identity
resource "aws_ses_domain_identity" "this" {
  domain = var.mail_domain
}

# DKIM para el dominio SES
resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

# (Opcional) SES Mail FROM Domain
resource "aws_ses_domain_mail_from" "this" {
  domain                 = aws_ses_domain_identity.this.domain
  mail_from_domain       = "mail.${aws_ses_domain_identity.this.domain}"
  behavior_on_mx_failure = "UseDefaultValue"
}

# Política para permitir que la cola sea usada (ej: por lambdas)
resource "aws_sqs_queue_policy" "allow_ses" {
  queue_url = aws_sqs_queue.mail_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action   = "SQS:SendMessage"
        Resource = aws_sqs_queue.mail_queue.arn
      }
    ]
  })
}
