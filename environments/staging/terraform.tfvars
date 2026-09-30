aws_region         = "ap-south-1"
environment        = "staging"
project_name       = "terraform-aws-3tier-platform"
owner              = "DevOps"
cost_center        = "DevOps-Staging"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["ap-south-1a", "ap-south-1b"]

public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
private_db_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]

single_nat_gateway = true

container_image = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
container_port  = 80
ecs_cpu         = 512
ecs_memory      = 1024

ecs_desired_count = 2
ecs_min_capacity  = 2
ecs_max_capacity  = 5

target_cpu_utilization    = 60
target_memory_utilization = 70

rds_engine_version         = "15.4"
rds_instance_class         = "db.t4g.small"
rds_allocated_storage      = 50
multi_az                   = false
backup_retention_period    = 7
enable_deletion_protection = false
skip_final_snapshot        = true

domain_name      = ""
record_subdomain = "staging"

tags = {
  Purpose = "Staging Pre-Production Environment"
}
