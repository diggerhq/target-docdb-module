variable "engine_version" {
}

variable "vpc_id" {}

variable "private_subnets" {}

variable "security_groups" {}

variable "tags" {}


variable "aws_app_identifier" {}

variable "cluster_identifier" {
}

variable "master_username" {
  default = "digger"
}

variable "port" {
  default = 27017
}

variable "instances_number" {
  default = 1
}

variable "instance_class" {
  default = "db.t3.medium"
}

variable "engine" {
  default = "docdb"
}


