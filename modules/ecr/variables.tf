variable "name" {
  description = "Nombre del repositorio ECR"
  type        = string
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
}
