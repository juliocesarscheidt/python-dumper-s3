variable "enabled" {
  type        = bool
  description = "Enabled"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "sa-east-1"
}

variable "ecs_cluster" {
  description = "ECS cluster name"
}

variable "task_schedule_expressions" {
  description = "Task schedule expressions in cron/rate format"
  type        = list(string)
  default     = ["cron(00 * * * ? *)"]
}

variable "task_count" {
  description = "Task count"
  type        = number
  default     = 1
}

variable "task_container_ports" {
  description = "Task container ports"
  type        = list
  default     = []
}

variable "task_container_command" {
  description = "Task container starting command"
  type        = list
  default     = []
}

variable "task_container_environment" {
  description = "Task container environment"
  type        = list(map(string))
  default     = []
}

variable "task_bucket_name" {
  description = "Bucket name for task"
  type        = string
}

variable "application_memory" {
  description = "Application Memory"
  type        = number
  default     = 4096
}

variable "application_cpu" {
  description = "CPU units"
  type        = number
  default     = 2048
}

variable "memory_reservation" {
  description = "Memory reservation"
  type        = number
  default     = 1024
}

variable "ecs_private_01_cidr" {
  description = "Public 0.0 CIDR for externally accessible subnet"
  type        = string
}

variable "ecs_private_02_cidr" {
  description = "Public 0.0 CIDR for externally accessible subnet"
  type        = string
}

variable "application_name" {
  description = "Application Name"
  type        = string
  default     = ""
}

variable "docker_registry" {
  description = "Docker Registry"
  type        = string
  default     = ""
}

variable "existent_vpc_id" {
  description = "Existent VPC ID"
  type        = string
  default     = ""
}

variable "existent_subnet_01_id" {
  description = "Existent Subnet 01 ID"
  type        = string
  default     = ""
}

variable "existent_subnet_02_id" {
  description = "Existent Subnet 01 ID"
  type        = string
  default     = ""
}

variable "task_assign_public_ip" {
  description = "Should we assign a public IP to the task"
  type        = bool
  default     = false
}

variable "allowed_ports" {
  description = "List of allowed ingress ports"
  type        = list(number)
  default     = [22, 80, 443]
}

variable "build_number" {
  description = "Build Number from Jenkins"
  type        = string
}

variable "event_target_input_commands" {
  description = "Event target input commands"
  type        = list
  default     = []
}

variable "tags" {
  description = "Additional tags (_e.g._ { BusinessUnit : ABC })"
  type        = map(string)
  default     = {}
}
