# Environment variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "AWS region must be in format: us-east-1, eu-west-1, etc."
  }
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "products"
  
  validation {
    condition     = length(var.dynamodb_table_name) >= 3 && length(var.dynamodb_table_name) <= 255
    error_message = "Table name must be between 3 and 255 characters."
  }
}

# SSM Parameter Store configuration
variable "ssm_parameter_name" {
  description = "Name of the SSM Parameter Store resource"
  type        = string
  
  validation {
    condition     = length(var.ssm_parameter_name) >= 3 && length(var.ssm_parameter_name) <= 255
    error_message = "SSM parameter name must be between 3 and 255 characters."
  }
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.ssm_parameter_name))
    error_message = "SSM parameter name must start with a letter and contain only letters, numbers, and hyphens."
  }
}