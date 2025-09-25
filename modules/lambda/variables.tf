variable "name" {
  description = "Nombre de la función Lambda"
  type        = string
}

variable "s3_bucket" {
  description = "Bucket S3 donde está el zip de la Lambda"
  type        = string
}

variable "s3_key" {
  description = "Key del archivo zip de la Lambda en S3"
  type        = string
}

variable "handler" {
  description = "Handler de la Lambda (ej: index.handler)"
  type        = string
}

variable "runtime" {
  description = "Runtime de la Lambda (ej: nodejs18.x, python3.11)"
  type        = string
}

variable "environment" {
  description = "Variables de entorno de la Lambda"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {}
}

variable "sqs_arn" {
  description = "ARN de la SQS que la Lambda va a consumir"
  type        = string
  default     = null # ⬅️ opcional
}

variable "event_sources" {
  description = "Lista de event sources para la Lambda (SQS, etc.)"
  type = list(object({
    type = string
    arn  = string
  }))
  default = [] # ⬅️ vacío por defecto
}
