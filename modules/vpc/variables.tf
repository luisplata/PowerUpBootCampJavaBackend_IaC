variable "prefix" {
  type        = string
  description = "Prefijo para nombrar los recursos"
}

variable "cidr_block" {
  type        = string
  description = "Bloque CIDR de la VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "Lista de CIDRs para subnets públicas"
}

variable "private_subnets" {
  type        = list(string)
  description = "Lista de CIDRs para subnets privadas"
}

variable "azs" {
  type        = list(string)
  description = "Lista de zonas de disponibilidad"
}

variable "tags" {
  type        = map(string)
  default     = {}
}
