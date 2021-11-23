module "security_group" {
  enabled            = var.enabled
  source             = "./modules/security-group"
  tags               = var.tags
  vpc_id             = var.existent_vpc_id
  ecs_public_01_cidr = var.ecs_private_01_cidr
  ecs_public_02_cidr = var.ecs_private_02_cidr
  allowed_ports      = var.allowed_ports
}

# ECS job
module "ecs_job" {
  enabled                     = var.enabled
  source                      = "./modules/ecs-job"
  aws_region                  = var.aws_region
  ecs_cluster                 = var.ecs_cluster
  task_schedule_expressions   = var.task_schedule_expressions
  task_count                  = var.task_count
  task_container_ports        = var.task_container_ports
  task_container_command      = var.task_container_command
  event_target_input_commands = var.event_target_input_commands
  task_container_environment = concat(var.task_container_environment, [{
    "name" : "BUCKET_NAME", "value" : var.task_bucket_name
  }])
  application_memory      = var.application_memory
  application_cpu         = var.application_cpu
  memory_reservation      = var.memory_reservation
  docker_registry         = var.docker_registry
  build_number            = var.build_number
  task_subnet_ids         = [var.existent_subnet_01_id, var.existent_subnet_02_id]
  task_security_group_ids = [module.security_group.sg_id]
  task_assign_public_ip   = var.task_assign_public_ip
  application_name        = var.application_name
  task_role_arn           = local.aws_iam_role_task_role_arn
  execution_role_arn      = local.aws_iam_role_execution_role_arn
  tags                    = var.tags
}
