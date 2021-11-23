variable "enabled" {
  description = "Count"
  default     = true
}

variable "vpc_id" {
  description = "ID for VPC"
}

variable "allowed_ports" {
  type        = list(number)
  description = "List of allowed ingress ports"
  default     = [22, 80]
}

variable "ecs_public_01_cidr" {
  description = "Public 0.0 CIDR for externally accessible subnet"
}

variable "ecs_public_02_cidr" {
  description = "Public 0.0 CIDR for externally accessible subnet"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (_e.g._ { BusinessUnit : ABC })"
  default     = {}
}
