variable "aws_credentials_file" {}
variable "region" {}

variable "vpc_name" {}

variable "vpc_cidr_block" {
  description = "IPv4 CIDR assigned to VPC"
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "If true, instances receive public DNS hostnames"
  default     = true
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default     = "10.0.1.0/24"
}
