terraform {  
  required_version = ">= 1.4.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source to fetch your existing VPC details
data "aws_vpc" "selected" {
  id = var.vpc_id
}