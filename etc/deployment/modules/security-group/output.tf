output "sg_id" {
  value = concat(aws_security_group.public_sg.*.id, [""])[0]
}
