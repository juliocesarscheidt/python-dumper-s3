resource "aws_cloudwatch_event_rule" "cloudwatch-event-rule" {
  count               = var.enabled ? length(var.task_schedule_expressions) : 0
  name                = "event-rule-${var.application_name}-${count.index}"
  schedule_expression = var.task_schedule_expressions[count.index]
  tags = merge(var.tags, {
    "Name" = "event-rule-${var.application_name}"
  })
}

data "aws_ecs_cluster" "ecs-cluster" {
  cluster_name = var.ecs_cluster
}

locals {
  cloudwatch_event_rule_name = var.enabled ? aws_cloudwatch_event_rule.cloudwatch-event-rule[0].name : ""
  cloudwatch_event_role_arn  = var.enabled ? aws_iam_role.cloudwatch-event-role[0].arn : ""
}

resource "aws_cloudwatch_event_target" "cloudwatch-event-target" {
  count     = var.enabled ? length(var.task_schedule_expressions) : 0
  target_id = "event-target-${var.application_name}-${count.index}"
  arn       = data.aws_ecs_cluster.ecs-cluster.arn
  rule      = local.cloudwatch_event_rule_name
  role_arn  = local.cloudwatch_event_role_arn
  ecs_target {
    task_count          = var.task_count
    task_definition_arn = aws_ecs_task_definition.task-definition[0].arn
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = var.task_subnet_ids
      security_groups  = var.task_security_group_ids
      assign_public_ip = var.task_assign_public_ip
    }
  }
  input = jsonencode({
    containerOverrides : [
      {
        name : var.application_name,
        command : var.event_target_input_commands
      }
    ]
  })
  depends_on = [
    local.cloudwatch_event_rule_name,
    local.cloudwatch_event_role_arn,
    aws_ecs_task_definition.task-definition,
  ]
}
