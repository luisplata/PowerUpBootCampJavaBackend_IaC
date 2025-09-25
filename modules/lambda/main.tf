resource "aws_lambda_function" "this" {
  function_name = var.name
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key
  handler       = var.handler
  runtime       = var.runtime
  role          = aws_iam_role.lambda_exec.arn

  environment {
    variables = var.environment
  }

  tags = var.tags
}

# IAM Role for Lambda execution
resource "aws_iam_role" "lambda_exec" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Basic Lambda execution policy (logs, etc.)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Extra event sources (SQS, Dynamo, etc.)
resource "aws_lambda_event_source_mapping" "this" {
  count = length(var.event_sources)

  function_name    = aws_lambda_function.this.arn
  event_source_arn = var.event_sources[count.index].arn
  batch_size       = 10
  enabled          = true
}

resource "aws_iam_role_policy" "sqs_access" {
  count = length(var.event_sources)
  name = "${var.name}-sqs-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.event_sources[count.index].arn
      }
    ]
  })
}
