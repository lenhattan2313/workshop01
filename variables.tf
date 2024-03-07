variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "availability_zones" {
  default = ["ap-southeast-1a", "ap-southeast-1b"]  
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
  default = ["10.10.1.0/24", "10.10.2.0/24"] 
}

variable "vpc_cidr_block" {
  default = "10.10.0.0/16"
}

variable "ami" {
  default = "ami-07a6e3b1c102cdba8"
  
}

variable "instance_type" {
  default = "t2.micro"
  
}