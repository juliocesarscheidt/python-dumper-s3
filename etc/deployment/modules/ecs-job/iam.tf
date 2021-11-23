#### for cloudwatch ####
resource "aws_iam_role" "cloudwatch-event-role" {
  count              = var.enabled ? 1 : 0
  name               = "cloudwatch-event-role-${var.application_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch-event-role-policy" {
  count  = var.enabled ? 1 : 0
  name   = "cloudwatch-event-role-policy-${var.application_name}"
  role   = aws_iam_role.cloudwatch-event-role[0].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:RunTask"
      ],
      "Resource": [
        "*"
      ]
    }, {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
  depends_on = [
    aws_iam_role.cloudwatch-event-role,
  ]
}
