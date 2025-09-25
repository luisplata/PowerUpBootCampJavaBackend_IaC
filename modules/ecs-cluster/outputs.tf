output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "private_subnet_ids" {
  value = var.private_subnet_ids
}
