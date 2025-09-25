variable "identifier" {}
variable "db_name" {}
variable "username" {}
variable "password" {}
variable "subnet_ids" { type = list(string) }
variable "sg_ids"     { type = list(string) }
variable "tags"       { type = map(string) }
variable "instance_class" { default = "db.t3.micro" }
variable "allocated_storage" { default = 20 }
variable "max_allocated_storage" { default = 100 }