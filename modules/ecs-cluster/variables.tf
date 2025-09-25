variable "name" {}
variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }
variable "tags" {
  type = map(string)
}
