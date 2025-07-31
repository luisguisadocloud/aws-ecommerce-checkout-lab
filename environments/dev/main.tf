terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Common tags for all resources
locals {
  common_tags = {
    Project     = "ecommerce-checkout"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "luisguisado"
    CostCenter  = "portfolio"
    Version     = "1.0.0"
  }
}

# DynamoDB module
module "dynamodb_products" {
  source = "../../modules/dynamodb"
  table_name = var.dynamodb_table_name
  environment = var.environment
}
