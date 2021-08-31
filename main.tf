provider "aws" {
    region = "us-east-2"
    version = "~> 3.0"
  }
terraform {
    backend "s3" {
      bucket = "waynerbucktohio"
    #  dynamodb_table = "terraform-state-lock-dynamo"
     # key = "terraform-teste.tfstate"
      region = "us-east-2"
      #encrypted = true
    }
}
