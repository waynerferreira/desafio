provider "aws" {
    region = "us-east-2"
    version = "~> 3.0"
  }
terraform {
    backend "s3" {
      bucket = "waynerbucktohio"
    ##  dynamodb_table = "terraform-state-lock-dynamo"
    #  key = ""
      access_key = ${{ secrets.AWS_ACCESS_KEY_ID }}
      secret_key = ${{ secrets.AWS_SECRET_ACCESS_KEY }}  
      region = "us-east-2"
      #encrypted = true
    }
}
