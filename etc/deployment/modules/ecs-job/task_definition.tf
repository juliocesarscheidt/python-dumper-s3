resource "aws_ecs_task_definition" "task-definition" {
  count              = var.enabled ? 1 : 0
  family             = var.application_name
  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn
  container_definitions = jsonencode([
    {
      name : var.application_name
      image : "${var.docker_registry}/${var.application_name}:${var.build_number}",
      portMappings = var.task_container_ports != null ? [for port in [var.task_container_ports] : {
        containerPort = port
        hostPort      = port
      }] : [],
      command : var.task_container_command,
      environment : length(var.task_container_environment) > 0 ? var.task_container_environment : null,
      cpu : var.application_cpu,
      memory : var.application_memory,
      memoryReservation : var.memory_reservation,
      essential : true,
      logConfiguration = {
        logDriver = "awslogs",
        Options = {
          "awslogs-region"        = var.aws_region,
          "awslogs-group"         = var.application_name,
          "awslogs-stream-prefix" = "ecs",
        }
      }
    }
  ])
  network_mode             = "awsvpc"
  cpu                      = var.application_cpu
  memory                   = var.application_memory
  requires_compatibilities = ["FARGATE"]
  tags = merge(var.tags, {
    "Name" = var.application_name
  })
  depends_on = [
    var.task_role_arn,
    var.execution_role_arn,
  ]
}
