variable "name" {
  description = "Nombre del API Gateway"
  type        = string
}

variable "lambda_arn" {
  description = "ARN de la Lambda que expone el API"
  type        = string
}

variable "stage" {
  description = "Stage del API (ej: dev, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {}
}
