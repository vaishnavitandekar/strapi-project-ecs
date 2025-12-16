variable "db_username" {
  default = "strapi"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  default = "ap-south-1"
}
