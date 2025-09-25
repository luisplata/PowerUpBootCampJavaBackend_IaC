# infra/envs/dev/outputs.tf
output "dynamo_table_name" {
  description = "DynamoDB table name (dev)"
  value       = module.dynamodb.table_name
}

output "auth_db_endpoint" {
  description = "Auth DB endpoint (host:port)"
  value       = module.rds_auth.endpoint
}

output "solicitudes_db_endpoint" {
  description = "Solicitudes DB endpoint (host:port)"
  value       = module.rds_solicitudes.endpoint
}

output "ecs_cluster_id" {
  description = "ECS cluster id"
  value       = module.ecs_cluster.cluster_id
}

output "ecr_auth_repo" {
  description = "ECR repo URL for auth"
  value       = module.ecr_auth.repository_url
}

output "sqs_mail_queue_url" {
  description = "URL de la cola SQS de envío de correo"
  value       = module.sqs_ses.mail_queue_url
}

output "lambda_envio_correo_name" {
  description = "Lambda name (envio correo)"
  value       = module.lambda_envio_correo.lambda_name
}


# ---------------------------
# Outputs
# ---------------------------
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "ecr_solicitudes_repo" {
  value = module.ecr_solicitudes.repository_url
}

output "ecr_reporte_repo" {
  value = module.ecr_reporte.repository_url
}

output "capacidad_api_endpoint" {
  value = module.api_capacidad.api_endpoint
}


output "sqs_mail_queue_arn" {
  value = module.sqs_ses.mail_queue_arn
}

output "lambda_capacidad_name" {
  value = module.lambda_capacidad.lambda_name
}
