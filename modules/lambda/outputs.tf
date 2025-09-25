output "lambda_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "role_name" {
  value = aws_iam_role.lambda_exec.name
}

output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}