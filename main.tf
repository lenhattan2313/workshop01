provider "aws" {
  region  = "ap-southeast-1"
  profile = "WorkshopUser"
}


terraform {
  backend "s3" {
    bucket         = "terraform-workshop-01"
    key            = "tanle/terraform/remote/s3/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-workshop-01-locking"
  }
}

