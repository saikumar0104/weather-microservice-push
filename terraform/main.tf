provider "aws" {
  region = var.region
}

# ✅ Get AWS account ID (used for existing IAM role reference)
data "aws_caller_identity" "current" {}

# ✅ ECS Cluster
resource "aws_ecs_cluster" "weather_cluster" {
  name = "weather-cluster"
}
# ✅ Security Group for ECS Tasks
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-weather-push-sg"
  description = "Allow inbound traffic for Weather Microservice"
  vpc_id      = var.vpc_id

  # Allow HTTP traffic for the microservice
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow PostgreSQL access
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 9091
    to_port     = 9091
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ CloudWatch Log Group for ECS container logs
resource "aws_cloudwatch_log_group" "weather_logs" {
  name              = "/ecs/weather-push-microservice"
  retention_in_days = 7
}

# ✅ ECS Task Definition (reuses existing IAM Role)
resource "aws_ecs_task_definition" "weather_push_task" {
  family                   = "weather-push-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"

  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name  = "weather-microservice"
      image = var.docker_image
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        { name = "POSTGRES_URL", value = var.spring_datasource_url },
        { name = "POSTGRES_USER", value = var.spring_datasource_username },
        { name = "POSTGRES_PASSWORD", value = var.spring_datasource_password },
        { name = "PUSHGATEWAY_URL", value = var.pushgateway_url }      
]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.weather_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# ✅ ECS Service
resource "aws_ecs_service" "weather_push_service" {
  name            = "weather-push-service"
  cluster         = aws_ecs_cluster.weather_cluster.id
  task_definition = aws_ecs_task_definition.weather_push_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

terraform {
  backend "s3" {
    bucket         = "s3bucketweather"    # replace with your S3 bucket name
    key            = "weatherpush/terraform.tfstate"
    region         = "ap-south-1"
  }
}

