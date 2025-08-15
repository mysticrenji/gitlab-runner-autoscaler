terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.76.1"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.aws_region
}