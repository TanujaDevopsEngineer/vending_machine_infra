resource "aws_ecs_cluster" "main" {
  name = "vending-machine-cluster"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/vending-machine"
  retention_in_days = 7
  tags = {
    Name = "vending-machine-ecs-logs"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "vending-machine-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  container_definitions    = jsonencode([{
    name  = "vending-machine"
    image = "112736993507.dkr.ecr.eu-west-2.amazonaws.com/vending-machine:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/vending-machine"
        awslogs-region        = "eu-west-2"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
  depends_on = [aws_ecs_cluster.main, aws_cloudwatch_log_group.ecs]
}

resource "aws_ecs_service" "main" {
  name            = "vending-machine-cluster-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "vending-machine"
    container_port   = 3000
  }
  depends_on = [
    aws_ecs_task_definition.main,
    var.alb_arn,
    aws_security_group.ecs
  ]
}

resource "aws_security_group" "ecs" {
  vpc_id = var.vpc_id
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [var.vpc_id]
}

resource "aws_iam_role" "ecs_execution" {
  name = "vending-machine-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ecs_execution" {
  name   = "ecs-execution-policy"
  role   = aws_iam_role.ecs_execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}