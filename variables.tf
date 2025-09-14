variable "aws_region" {
  description = "Région AWS"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
}

variable "public_subnets" {
  description = "Liste des CIDR des subnets publics"
  type        = list(string)
}

variable "private_subnets" {
  description = "Liste des CIDR des subnets privés"
  type        = list(string)
}

variable "availability_zones" {
  description = "AZs utilisées"
  type        = list(string)
}
