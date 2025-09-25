output "mail_queue_arn" {
  value = aws_sqs_queue.mail_queue.arn
}

output "mail_queue_url" {
  value = aws_sqs_queue.mail_queue.id
}

output "ses_domain_identity" {
  value = aws_ses_domain_identity.this.domain
}

output "ses_dkim_tokens" {
  value = aws_ses_domain_dkim.this.dkim_tokens
}
