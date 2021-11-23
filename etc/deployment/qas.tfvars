enabled                   = true
aws_region                = "sa-east-1"
ecs_cluster               = "ecs-cluster-qas"
task_schedule_expressions = ["cron(00 03 ? * MON-FRI *)"]
task_count                = 1
task_container_ports      = null
task_container_command    = []
task_container_environment = [
  { "name" : "ENV", "value" : "qas" },
  { "name" : "DUMP_MODE", "value" : "database" },
  { "name" : "MAX_TABLES", "value" : "" },
  { "name" : "PARALLEL_PROCESSES_NUM", "value" : "2" },
  { "name" : "CLEAN_FILES", "value" : "True" },
]
task_bucket_name            = "bucket-backup-ia"
application_memory          = 4096
application_cpu             = 2048
memory_reservation          = 1024
ecs_private_01_cidr         = "x.x.x.x/24"
ecs_private_02_cidr         = "x.x.x.x/24"
application_name            = "python-dumper-s3-qas"
docker_registry             = "000000000000.dkr.ecr.sa-east-1.amazonaws.com"
existent_vpc_id             = "vpc-00000000000000000"
existent_subnet_01_id       = "subnet-00000000000000000"
existent_subnet_02_id       = "subnet-00000000000000000"
task_assign_public_ip       = false
allowed_ports               = [22]
event_target_input_commands = ["dumper_database"]
tags = {
  "ENVIRONMENT" = "QAS"
  "PROVIDER"    = "TERRAFORM"
}
