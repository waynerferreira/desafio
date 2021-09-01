terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
    region = "us-east-2"
  }
terraform {
    backend "s3" {
      bucket = "waynerbucktohio"
    ##  dynamodb_table = "terraform-state-lock-dynamo"
    #  key = ""
      key = "terraform-teste.tfstate"
      region = "us-east-2"
      #encrypted = true
    }
}
