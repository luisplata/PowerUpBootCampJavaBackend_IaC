resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  dynamic "attribute" {
    for_each = var.range_key != null ? [var.range_key] : []
    content {
      name = attribute.value
      type = "S"
    }
  }

  tags = merge(
    {
      Environment = var.environment
      Project     = var.project
    },
    var.tags
  )
}
