variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ecommerce-checkout"
}

variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "luisguisado"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "portfolio"
}

variable "version" {
  description = "Version of the infrastructure"
  type        = string
  default     = "1.0.0"
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

locals {
  standard_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Version     = var.version
    CreatedAt   = timestamp()
  }
  
  all_tags = merge(local.standard_tags, var.additional_tags)
}

output "tags" {
  description = "Standard tags for resources"
  value       = local.all_tags
}

output "standard_tags" {
  description = "Standard tags without additional tags"
  value       = local.standard_tags
} 