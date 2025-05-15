resource "aws_api_gateway_rest_api" "main" {
  name = "vending-machine-api"
  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [var.vpc_endpoint_id]
  }
  depends_on = [var.vpc_endpoint_id]
}

resource "aws_api_gateway_resource" "ingredients" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "ingredients"
  depends_on  = [aws_api_gateway_rest_api.main]
}

resource "aws_api_gateway_method" "ingredients_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.ingredients.id
  http_method   = "GET"
  authorization = "NONE"
  depends_on    = [aws_api_gateway_resource.ingredients]
}

resource "aws_api_gateway_integration" "ingredients" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.ingredients.id
  http_method             = aws_api_gateway_method.ingredients_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.alb_dns_name}/ingredients"
  timeout_milliseconds    = 29000
  depends_on              = [aws_api_gateway_method.ingredients_get, var.alb_dns_name]
}

resource "aws_api_gateway_rest_api_policy" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowFromSpecificVPCEndpoint",
        Effect    = "Allow",
        Principal = "*",
        Action    = "execute-api:Invoke",
        Resource  = "${aws_api_gateway_rest_api.main.execution_arn}/*/GET/ingredients",
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = var.vpc_endpoint_id
          }
        }
      },
      {
        Sid       = "DenyEveryoneElse",
        Effect    = "Deny",
        Principal = "*",
        Action    = "execute-api:Invoke",
        Resource  = "${aws_api_gateway_rest_api.main.execution_arn}/*/GET/ingredients",
        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = var.vpc_endpoint_id
          }
        }
      }
    ]
  })
}


resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.ingredients.id,
      aws_api_gateway_method.ingredients_get.id,
      aws_api_gateway_integration.ingredients.id,
      aws_api_gateway_rest_api_policy.main,
      timestamp()
    ]))
  }
  depends_on = [aws_api_gateway_integration.ingredients, aws_api_gateway_rest_api_policy.main]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.main.id
  stage_name    = "prod"
  cache_cluster_enabled = false
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
  depends_on = [aws_api_gateway_deployment.main, aws_cloudwatch_log_group.api_gateway, aws_api_gateway_account.main]
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "prod"
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
  depends_on = [aws_api_gateway_stage.prod]
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/vending-machine-api"
  retention_in_days = 7
}

resource "aws_iam_role" "api_gateway_logging" {
  name = "api-gateway-logging-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "api_gateway_logging" {
  name   = "api-gateway-logging-policy"
  role   = aws_iam_role.api_gateway_logging.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "arn:aws:logs:eu-west-2:112736993507:log-group:/aws/apigateway/*:*"
      }
    ]
  })
}

resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_logging.arn
  depends_on          = [aws_iam_role.api_gateway_logging, aws_iam_role_policy.api_gateway_logging]
}