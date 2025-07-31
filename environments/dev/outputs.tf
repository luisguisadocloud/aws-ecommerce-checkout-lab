# Development environment outputs

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb_products.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb_products.table_arn
}

output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}