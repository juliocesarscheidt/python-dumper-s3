#### role for ECS task execution ####
resource "aws_iam_role" "execution-role" {
  count              = var.enabled ? 1 : 0
  name               = "execution-role-${var.application_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "execution-policy" {
  count = var.enabled ? 1 : 0
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ssm:GetParameters",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}

resource "aws_iam_role_policy" "execution-role-policy" {
  count  = var.enabled ? 1 : 0
  role   = local.aws_iam_role_execution_role_id
  name   = "execution-role-policy-${var.application_name}"
  policy = data.aws_iam_policy_document.execution-policy[0].json
  depends_on = [
    local.aws_iam_role_execution_role_id,
    data.aws_iam_policy_document.execution-policy,
  ]
}

#### role for ECS task application ####
resource "aws_iam_role" "task-role" {
  count              = var.enabled ? 1 : 0
  name               = "task-role-${var.application_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "aws_caller_identity" "current_caller_identity" {
}

locals {
  account_id = data.aws_caller_identity.current_caller_identity.account_id
}

data "aws_iam_policy_document" "task-policy" {
  count = var.enabled ? 1 : 0
  statement {
    effect = "Allow"
    resources = [
      "*",
    ]
    actions = [
      "s3:ListAllMyBuckets",
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${var.task_bucket_name}",
    ]
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${var.task_bucket_name}/*",
    ]
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${local.account_id}:secret:app/mysql/dev",
      "arn:aws:secretsmanager:${var.aws_region}:${local.account_id}:secret:app/mysql/qas",
      "arn:aws:secretsmanager:${var.aws_region}:${local.account_id}:secret:app/mysql/prd",
    ]
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      "*",
    ]
    actions = [
      "secretsmanager:ListSecrets",
    ]
  }
}

resource "aws_iam_role_policy" "task-role-policy" {
  count  = var.enabled ? 1 : 0
  role   = local.aws_iam_role_task_role_id
  name   = "task-role-policy-${var.application_name}"
  policy = data.aws_iam_policy_document.task-policy[0].json
  depends_on = [
    local.aws_iam_role_task_role_id,
    data.aws_iam_policy_document.task-policy,
  ]
}
