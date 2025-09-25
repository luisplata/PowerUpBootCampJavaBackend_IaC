variable "table_name" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
}

variable "hash_key" {
  description = "Clave primaria (HASH key)"
  type        = string
}

variable "range_key" {
  description = "Clave de rango (opcional)"
  type        = string
  default     = null
}

variable "environment" {
  description = "Nombre del ambiente (dev, prod, etc.)"
  type        = string
}

variable "project" {
  description = "Nombre del proyecto o aplicación"
  type        = string
}

variable "tags" {
  description = "Map de tags a aplicar"
  type        = map(string)
  default     = {}
}
