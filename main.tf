terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.10.0"
    }
  }

  backend "s3" {
    bucket ="kafka-infrastructure-state"
    key = "state"
    region = "us-east-1"
    dynamodb_table = "tfremotestate-infrastructure"
  }
}


provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow public access to Kafka
  }

  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow public access to Kafka
  }

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow public access to Zookeeper
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = "my-ecs-cluster"
}

resource "aws_ecs_task_definition" "multi_broker_kafka" {
  family                = "terraform_aws"
  requires_compatibilities = ["FARGATE"]
  network_mode         = "awsvpc"
  cpu                  = "256"
  memory               = "512"
  container_definitions = jsonencode(jsondecode(file(var.task_definition_file)).containerDefinitions)
}

resource "aws_ecs_service" "multi_container_service" {
  name            = "my-kafka-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.multi_broker_kafka.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
