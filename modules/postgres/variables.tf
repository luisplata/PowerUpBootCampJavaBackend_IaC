variable "env" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }

variable "engine_version" { default = "15.5" }
variable "instance_class" { default = "db.t3.micro" }
variable "allocated_storage" { default = 20 }
variable "max_allocated_storage" { default = 100 }

variable "username" { type = string }
variable "password" { type = string }
