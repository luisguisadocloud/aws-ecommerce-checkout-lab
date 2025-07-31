terraform {
  backend "s3" {
    bucket         = "ecommerce-checkout-terraform-state-1753928514"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
