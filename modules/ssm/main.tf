resource "aws_ssm_parameter" "ps_ecommerce_params" {
  name        = var.ssm_parameter_name
  description = "Parameter store"
  type        = "SecureString"
  value       = file("${path.module}/resource/config.json")

  tags = {
    Environment = var.environment
  }
}
