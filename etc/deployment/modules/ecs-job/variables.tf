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
  # e.g. [{ "name" : "NODE_ENV", "value" : "development" }]
  default = []
}

variable "application_memory" {
  type        = number
  description = "Application Memory"
  default     = 4096
}

variable "application_cpu" {
  type        = number
  description = "CPU units"
  default     = 2048
}

variable "memory_reservation" {
  type        = number
  description = "Memory reservation"
  default     = 1024
}

variable "task_subnet_ids" {
  type        = list
  description = "The subnet IDs for task"
}

variable "task_security_group_ids" {
  type        = list
  description = "The security group IDs for task"
}

variable "task_assign_public_ip" {
  description = "Should we assign a public IP to the task"
  type        = bool
  default     = false
}

variable "build_number" {
  description = "CI build number"
  type        = string
  default     = ""
}

variable "event_target_input_commands" {
  description = "Event target input commands"
  type        = list
  default     = []
}

variable "application_name" {
  description = "Application name"
  type        = string
}

variable "task_role_arn" {
  description = "Task role ARN"
  type        = string
}

variable "execution_role_arn" {
  description = "Execution role ARN"
  type        = string
}

variable "docker_registry" {
  description = "Docker image registry"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (_e.g._ { BusinessUnit : ABC })"
  # e.g. { "BusinessUnit" : "ABC" }
  default = {}
}
