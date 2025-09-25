output "postgres_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "postgres_username" {
  value = aws_db_instance.this.username
}

output "postgres_dbname" {
  value = aws_db_instance.this.name
}
