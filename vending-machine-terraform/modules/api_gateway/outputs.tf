output "api_endpoint" {
  description = "API Gateway endpoint URL for the ingredients endpoint"
  value       = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/ingredients"
}