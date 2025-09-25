# infra/envs/dev/main.tf
# Orquestador del ambiente dev (usa módulos en ../../modules)

locals {
  prefix = "${var.prefix}-${var.env}"
  tags = {
    Environment = var.env
    Project     = "BootCampJavaWebFluxAws"
  }
  lambda_bucket = "${var.prefix}-lambda-artifacts-${var.env}"
}

# ---------------------------
# Networking (VPC + subnets)
# ---------------------------
module "vpc" {
  source          = "../../modules/vpc"
  prefix          = local.prefix
  cidr_block      = var.vpc_cidr
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs
  azs             = var.availability_zones
  tags            = local.tags
}

# ---------------------------
# Security Groups
# ---------------------------
resource "aws_security_group" "alb" {
  name        = "${local.prefix}-alb-sg"
  vpc_id      = module.vpc.vpc_id
  description = "ALB security group (http)"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "ecs" {
  name        = "${local.prefix}-ecs-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for ECS tasks"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "rds" {
  name        = "${local.prefix}-rds-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for RDS (allow from ECS SG)"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
    description     = "Allow Postgres from ECS tasks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# ---------------------------
# ALB + Listener
# ---------------------------
resource "aws_lb" "this" {
  name               = "${local.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnet_ids
  tags               = local.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Default 404"
      status_code  = "404"
    }
  }
}

# ---------------------------
# S3 bucket for Lambda artifacts
# ---------------------------
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = local.lambda_bucket
  tags   = merge(local.tags, { Name = "${local.prefix}-lambda-artifacts" })
}

resource "aws_s3_bucket_versioning" "lambda_bucket_versioning" {
  bucket = aws_s3_bucket.lambda_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_bucket_sse" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------------------------
# DynamoDB
# ---------------------------
module "dynamodb" {
  source      = "../../modules/dynamodb"
  table_name  = "${local.prefix}-reportes"
  hash_key    = "id"
  range_key   = null
  environment = var.env
  project     = "BootCampJavaWebFluxAws"
  tags        = local.tags
}

# ---------------------------
# RDS Postgres
# ---------------------------
module "rds_auth" {
  source     = "../../modules/rds-postgres"
  identifier = "${local.prefix}-auth-db"
  db_name    = "authdb"
  username   = "auth_admin"
  password   = var.db_admin_password_auth
  subnet_ids = module.vpc.private_subnet_ids
  sg_ids     = [aws_security_group.rds.id]
  tags       = local.tags
}

module "rds_solicitudes" {
  source     = "../../modules/rds-postgres"
  identifier = "${local.prefix}-solicitudes-db"
  db_name    = "solicitudesdb"
  username   = "sol_admin"
  password   = var.db_admin_password_solicitudes
  subnet_ids = module.vpc.private_subnet_ids
  sg_ids     = [aws_security_group.rds.id]
  tags       = local.tags
}

# ---------------------------
# ECS cluster
# ---------------------------
module "ecs_cluster" {
  source             = "../../modules/ecs-cluster"
  name               = "${local.prefix}-cluster"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  tags               = local.tags
}

# ---------------------------
# ECR repos
# ---------------------------
module "ecr_auth" {
  source = "../../modules/ecr"
  name   = "${local.prefix}/auth"
  tags   = local.tags
}

module "ecr_solicitudes" {
  source = "../../modules/ecr"
  name   = "${local.prefix}/solicitudes"
  tags   = local.tags
}

module "ecr_reporte" {
  source = "../../modules/ecr"
  name   = "${local.prefix}/reporte"
  tags   = local.tags
}

# ---------------------------
# ECS services (corrigiendo listener_arn)
# ---------------------------
module "ecs_service_auth" {
  source         = "../../modules/ecs-service"
  cluster_id     = module.ecs_cluster.cluster_id
  family         = "auth-task"
  service_name   = "auth-service"
  container_name = "auth-container"
  image          = module.ecr_auth.repository_url
  container_port = 8080
  cpu            = 512
  memory         = 1024
  desired_count  = 1
  subnet_ids     = module.vpc.private_subnet_ids
  sg_ids         = [aws_security_group.ecs.id]
  alb_sg_id      = aws_security_group.alb.id
  vpc_id         = module.vpc.vpc_id
  tags           = local.tags
  listener_arn   = aws_lb_listener.http.arn # ✅ ALB listener
  priority       = 100
}

module "ecs_service_solicitudes" {
  source         = "../../modules/ecs-service"
  cluster_id     = module.ecs_cluster.cluster_id
  family         = "solicitudes-task"
  service_name   = "solicitudes-service"
  container_name = "solicitudes-container"
  image          = module.ecr_solicitudes.repository_url
  container_port = 8080
  cpu            = 512
  memory         = 1024
  desired_count  = 1
  subnet_ids     = module.vpc.private_subnet_ids
  sg_ids         = [aws_security_group.ecs.id]
  alb_sg_id      = aws_security_group.alb.id
  vpc_id         = module.vpc.vpc_id
  tags           = local.tags
  listener_arn   = aws_lb_listener.http.arn # ✅ ALB listener
  priority       = 200
}

module "ecs_service_reporte" {
  source         = "../../modules/ecs-service"
  cluster_id     = module.ecs_cluster.cluster_id
  family         = "reporte-task"
  service_name   = "reporte-service"
  container_name = "reporte-container"
  image          = module.ecr_reporte.repository_url
  container_port = 8080
  cpu            = 512
  memory         = 1024
  desired_count  = 1
  subnet_ids     = module.vpc.private_subnet_ids
  sg_ids         = [aws_security_group.ecs.id]
  alb_sg_id      = aws_security_group.alb.id
  vpc_id         = module.vpc.vpc_id
  tags           = local.tags
  listener_arn   = aws_lb_listener.http.arn # ✅ ALB listener
  priority       = 300
}

# ---------------------------
# SQS + SES
# ---------------------------
module "sqs_ses" {
  source      = "../../modules/sqs-ses"
  name_prefix = local.prefix
  ses_from    = var.ses_from
  mail_domain = var.mail_domain
  tags        = local.tags
}

# ---------------------------
# Lambdas
# ---------------------------
module "lambda_capacidad" {
  source    = "../../modules/lambda"
  name      = "${local.prefix}-capacidad-fn"
  s3_bucket = "endeudamiento-dev-serverlessdeploymentbucket-kovpz6bxirtm"
  s3_key    = "serverless/endeudamiento/dev/1758207685141-2025-09-18T15:01:25.141Z/endeudamiento.zip"
  handler   = "src/infrastructure/handlers/calcularCapacidadHandler.calcularCapacidad"
  runtime   = "nodejs20.x"
  environment = {
    DYNAMO_TABLE = module.dynamodb.table_name
  }
  tags = local.tags
}

module "lambda_envio_correo" {
  source      = "../../modules/lambda"
  name        = "${local.prefix}-envio-correo-fn"
  s3_bucket   = "send-mail-dev-serverlessdeploymentbucket-zyobmw2e2btd"
  s3_key      = "serverless/send-mail/dev/1757381960239-2025-09-09T01:39:20.239Z/send-mail.zip"
  handler     = "src/handler.readSqsToEmail"
  runtime     = "nodejs20.x"
  environment = { SES_FROM = var.ses_from }
  event_sources = [
    {
      type = "sqs"
      arn  = module.sqs_ses.mail_queue_arn
    }
  ]
  tags    = local.tags
  sqs_arn = module.sqs_ses.mail_queue_arn
}

# ---------------------------
# API Gateway
# ---------------------------
module "api_capacidad" {
  source     = "../../modules/api-gateway"
  name       = "${local.prefix}-capacidad-api"
  lambda_arn = module.lambda_capacidad.lambda_arn
  stage      = "prod"
  tags       = local.tags
}
