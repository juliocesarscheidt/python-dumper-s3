locals {
  aws_iam_role_execution_role_id  = var.enabled ? aws_iam_role.execution-role[0].id : ""
  aws_iam_role_task_role_id       = var.enabled ? aws_iam_role.task-role[0].id : ""
  aws_iam_role_execution_role_arn = var.enabled ? aws_iam_role.execution-role[0].arn : ""
  aws_iam_role_task_role_arn      = var.enabled ? aws_iam_role.task-role[0].arn : ""
}
