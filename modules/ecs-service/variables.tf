variable "cluster_id" { type = string }
variable "family" { type = string }
variable "service_name" { type = string }
variable "container_name" { type = string }
variable "image" { type = string }
variable "container_port" { type = number }
variable "cpu" { type = number }
variable "memory" { type = number }
variable "desired_count" { type = number }
variable "subnet_ids" { type = list(string) }
variable "sg_ids" { type = list(string) }
variable "alb_sg_id" { type = string }
variable "vpc_id" { type = string }
variable "tags" { type = map(string) }
variable "listener_arn" {
  description = "ARN del listener del ALB"
  type        = string
}
variable "priority" { type = number }