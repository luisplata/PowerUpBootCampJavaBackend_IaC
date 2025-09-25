variable "name_prefix" {
  description = "Prefijo para nombrar recursos"
  type        = string
}

variable "ses_from" {
  description = "Email from (ej: no-reply@dominio.com)"
  type        = string
}

variable "mail_domain" {
  description = "Dominio para SES (ej: dominio.com)"
  type        = string
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {}
}
