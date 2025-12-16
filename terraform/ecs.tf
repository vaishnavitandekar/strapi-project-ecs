resource "aws_ecr_repository" "this" {
  name = "strapi-backend-vaishnavi-ecs"
}

resource "aws_ecs_cluster" "this" {
  name = "strapi-cluster-vaishnavi-ecs"
}

resource "aws_iam_role" "exec" {
  name = "ecsTaskExecutionRole-vaishnavi-ecs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "exec_policy" {
  role       = aws_iam_role.exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "strapi"
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.exec.arn

  container_definitions = jsonencode([{
    name  = "strapi-vaishnavi-ecs"
    image = "${aws_ecr_repository.this.repository_url}:latest"
    portMappings = [{ containerPort = 1337 }]
    environment = [
      { name = "DATABASE_HOST", value = aws_db_instance.postgres.address },
      { name = "DATABASE_PORT", value = "5432" },
      { name = "DATABASE_NAME", value = "strapi" },
      { name = "DATABASE_USERNAME", value = var.db_username },
      { name = "DATABASE_PASSWORD", value = var.db_password }
    ]
  }])
}

resource "aws_ecs_service" "service" {
  name            = "strapi-service-vaishnavi"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
