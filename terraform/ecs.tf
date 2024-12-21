# ECS IAM execution role


resource "aws_iam_role" "ecs-execution-iam" {
  name = "ecs-execution-iam"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"               # ECS service principal, from AWS Console.
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    tag-key = "values"
  }
}


# Execution role policy and logs attached

resource "aws_iam_role_policy_attachment" "ecs-execution-role-policy" {
  role       = aws_iam_role.ecs-execution-iam.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "threatmodel-logs" {
  name              = "/ecs/threatmodel-logs"
  retention_in_days = 7
}

resource "aws_iam_policy" "ecs-cloudwatch-policy" {
  name = "ecs-cloudwatch-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:eu-west-2:872515255126:log-group:/ecs/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs-execution-role-policy-attach" {
  role       = aws_iam_role.ecs-execution-iam.name
  policy_arn = aws_iam_policy.ecs-cloudwatch-policy.arn
}

# Task Definition #

resource "aws_ecs_task_definition" "app-task-definition" {
  family                   = "app-task-definition"
  execution_role_arn       = aws_iam_role.ecs-execution-iam.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 4096
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode([
    {
      name      = "threat-app-cluster"
      image     = "872515255126.dkr.ecr.eu-west-2.amazonaws.com/threat_app_image:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      logConfiguration = {
        logDriver : "awslogs"
        options : {
          "awslogs-group" : "/ecs/threatmodel-logs"
          "awslogs-create-group" : "true"
          "awslogs-region" : "eu-west-2"
          "awslogs-stream-prefix" : "ecs-logs"
        }
      }
    }
  ])
}



# ECS Cluster #

resource "aws_ecs_cluster" "threat-app-cluster" {
  name = "threat-app-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "fargate-capacity" {
  cluster_name       = aws_ecs_cluster.threat-app-cluster.name
  capacity_providers = ["FARGATE"]

}


# EC Service #      

resource "aws_ecs_service" "threat-ecs-service" {
  name            = "threat-ecs-service"
  cluster         = aws_ecs_cluster.threat-app-cluster.id      
  task_definition = aws_ecs_task_definition.app-task-definition.arn            # ECS task def.
  desired_count   = 1
  launch_type     = "FARGATE"

#     capacity_provider_strategy {
#   capacity_provider = "FARGATE"
#   weight            = 1
# }

  network_configuration {
    security_groups  = [ aws_security_group.threat-sg.id ]                      # referencing output on the same level
    subnets          = [ aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id ]
    assign_public_ip = false
  }

    load_balancer {
      target_group_arn = aws_lb_target_group.threat-fargate.arn
      container_name   = "threat-app-cluster"
      container_port   = 3000
    }
    deployment_controller {
    type = "ECS"

  }
  # depends_on = [var.listener_http_arn, var.listener_https_arn]
}
