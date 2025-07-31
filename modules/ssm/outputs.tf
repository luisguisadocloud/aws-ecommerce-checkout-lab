output "ssm_parameter_name" {
  value = aws_ssm_parameter.ps_ecommerce_params.name
}

output "ssm_parameter_arn" {
  value = aws_ssm_parameter.ps_ecommerce_params.arn
}
