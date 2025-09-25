# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = var.name
  tags = var.tags
}

# Optional: default capacity providers (solo Fargate)
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }
}

# Security group para servicios ECS
resource "aws_security_group" "ecs" {
  name        = "${var.name}-sg"
  description = "Security group for ECS services"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
