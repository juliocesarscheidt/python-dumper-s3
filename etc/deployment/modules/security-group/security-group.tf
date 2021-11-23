resource "aws_security_group" "public_sg" {
  count       = var.enabled ? 1 : 0
  name        = "ecs-sg-${random_id.id[0].hex}"
  description = "Security Group"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "egress" {
  count     = var.enabled ? 1 : 0
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_sg[0].id
}
resource "aws_security_group_rule" "ingress_range" {
  count     = var.enabled ? 1 : 0
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  cidr_blocks = [var.ecs_public_01_cidr, var.ecs_public_02_cidr]
  security_group_id = aws_security_group.public_sg[0].id
}

resource "aws_security_group_rule" "ingress_host_ports" {
  count     = var.enabled ? 1 : 0
  type      = "ingress"
  from_port = 29999
  to_port   = 39999
  protocol  = "tcp"
  cidr_blocks = [var.ecs_public_01_cidr, var.ecs_public_02_cidr]
  security_group_id = aws_security_group.public_sg[0].id
}

resource "aws_security_group_rule" "ingress" {
  count     = var.enabled ? length(compact(var.allowed_ports)) : 0
  type      = "ingress"
  from_port = var.allowed_ports[count.index]
  to_port   = var.allowed_ports[count.index]
  protocol  = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_sg[0].id
}

resource "random_id" "id" {
  count       = var.enabled ? 1 : 0
  byte_length = 8
}
