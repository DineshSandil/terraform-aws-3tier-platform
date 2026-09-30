aws_region         = "ap-south-1"
environment        = "prod"
project_name       = "terraform-aws-3tier-platform"
owner              = "DevOps"
cost_center        = "DevOps-Production"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["ap-south-1a", "ap-south-1b"]

public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
private_db_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]

# Production High Availability: 1 NAT Gateway per AZ
single_nat_gateway = false

# Container Configuration (2 vCPU, 4GB RAM)
container_image = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
container_port  = 80
ecs_cpu         = 1024
ecs_memory      = 2048

# High Availability ECS Service (3 to 10 tasks)
ecs_desired_count = 3
ecs_min_capacity  = 3
ecs_max_capacity  = 10

# Production Auto Scaling Thresholds
target_cpu_utilization    = 60
target_memory_utilization = 70

# Production Database (Multi-AZ, 30 days backup retention, deletion protection)
rds_engine_version         = "15.4"
rds_instance_class         = "db.r6g.large"
rds_allocated_storage      = 100
multi_az                   = true
backup_retention_period    = 30
enable_deletion_protection = true
skip_final_snapshot        = false

# Optional Custom Domain & Monitoring Alerts
domain_name      = ""
record_subdomain = "app"
alarm_email      = ""

tags = {
  Purpose    = "Production Workload"
  Compliance = "PCI-DSS-Ready"
}
