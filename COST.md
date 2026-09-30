# Cost Optimization & Pricing Breakdown

This document provides a comprehensive cost analysis, billing breakdown, and optimization strategy for the **terraform-aws-3tier-platform** across **dev**, **staging**, and **prod** environments.

---

## 1. Primary AWS Cost Drivers

Understanding the primary cost drivers in an AWS 3-tier architecture prevents unexpected cloud billing surprises.

| AWS Service | Billing Metric | Cost Intensity | Optimization Strategy Applied |
| :--- | :--- | :--- | :--- |
| **NAT Gateway** | \$0.045 / hour + \$0.045 / GB processed | 🔴 High | **Dev/Staging**: 1 NAT GW across AZs saves \$32.40/mo per AZ.<br>**Prod**: 2 NAT GWs for high availability. |
| **RDS PostgreSQL** | Compute instance-hour + Storage (GP3) + IOPS | 🔴 High | **Dev**: `db.t4g.micro` (Single-AZ, 20GB, \$13/mo).<br>**Prod**: `db.r6g.large` (Multi-AZ, 100GB, \$360/mo). |
| **ECS Fargate** | vCPU-hour (\$0.04048) + GB-hour (\$0.004445) | 🟡 Medium | **Dev**: 512 CPU / 1GB RAM, min 1 task.<br>**Prod**: 1024 CPU / 2GB RAM, target tracking autoscaling (3 to 10 tasks). |
| **Application Load Balancer** | \$0.0225 / hour + \$0.008 / LCU-hour | 🟡 Medium | Single ALB per environment; HTTP-to-HTTPS redirect; deregistration delay 30s. |
| **CloudWatch Logs & Metrics** | \$0.50 / GB ingested + \$0.10 / alarm / mo | 🟢 Low-Medium | **Dev**: 7-day retention, Container Insights off.<br>**Prod**: 90-day retention, Container Insights on. |
| **AWS KMS** | \$1.00 / CMK / month + API calls | 🟢 Low | 1 Customer Managed Key shared across tiers via aliases. |
| **Amazon S3** | \$0.023 / GB + PUT/GET API requests | 🟢 Very Low | S3 lifecycle rules automatically transition logs to STANDARD_IA (30d) and GLACIER (90d). |
| **Amazon ECR** | \$0.10 / GB / month storage | 🟢 Very Low | Lifecycle policies automatically prune untagged images and keep only the latest 10-50 tagged images. |
| **Route 53 & ACM** | \$0.50 / hosted zone / month (ACM is free) | 🟢 Very Low | Free public SSL/TLS certificates via AWS Certificate Manager. |

---

## 2. Monthly Cost Estimations by Environment

> *Estimates based on AWS region `ap-south-1` (Mumbai) standard on-demand pricing. Excludes Free Tier discounts.*

### Development (`environments/dev`) — **Cost-Optimized**
*Designed for minimal spend while maintaining realistic cloud architecture patterns.*

- **NAT Gateway (1x)**: ~\$32.40
- **ALB (1x + baseline LCUs)**: ~\$18.00
- **ECS Fargate (1 task, 0.5 vCPU, 1 GB RAM, 24/7)**: ~\$17.80
- **RDS PostgreSQL (`db.t4g.micro`, Single-AZ, 20 GB gp3)**: ~\$13.80
- **VPC Flow Logs & CloudWatch (7-day retention)**: ~\$2.50
- **KMS Customer Managed Key**: ~\$1.00
- **S3 & ECR**: ~\$1.00
- **Estimated Total**: **~\$86.50 / month**

---

### Staging (`environments/staging`) — **Pre-Production Validation**
*Designed to mimic production configuration with smaller compute sizes.*

- **NAT Gateway (1x)**: ~\$32.40
- **ALB (1x + baseline LCUs)**: ~\$19.50
- **ECS Fargate (2 tasks, 0.5 vCPU, 1 GB RAM)**: ~\$35.60
- **RDS PostgreSQL (`db.t4g.small`, Single-AZ, 50 GB gp3)**: ~\$29.50
- **CloudWatch Logs & Enhanced Monitoring**: ~\$6.00
- **KMS, S3, ECR**: ~\$2.50
- **Estimated Total**: **~\$125.50 / month**

---

### Production (`environments/prod`) — **High Availability & Fault Tolerant**
*Full multi-AZ redundancy, automated failover, deletion protection, and auto-scaling.*

- **NAT Gateways (2x across AZ-A & AZ-B for Multi-AZ)**: ~\$64.80
- **ALB (1x + production LCUs)**: ~\$30.00
- **ECS Fargate (3 baseline tasks, 1 vCPU, 2 GB RAM, 24/7)**: ~\$107.00
- **RDS PostgreSQL (`db.r6g.large`, Multi-AZ, 100 GB gp3, 30-day backups)**: ~\$385.00
- **CloudWatch Logs (90-day retention), Container Insights, Alarms**: ~\$15.00
- **KMS, S3, ECR**: ~\$3.50
- **Estimated Total**: **~\$605.30 / month**

---

## 3. Recommended Cost Reduction Actions

1. **Destroy Ephemeral Environments When Idle**:
   ```bash
   cd environments/dev
   terraform destroy -auto-approve
   ```
2. **Schedule Non-Production Uptime**:
   Use AWS EventBridge and Lambda or an Auto Scaling scheduled action to scale down dev ECS tasks to `0` outside of business hours (saving ~65% of ECS dev compute costs).
3. **Use Single NAT Gateway for Non-Production**:
   Ensure `single_nat_gateway = true` in `environments/dev/terraform.tfvars` and `environments/staging/terraform.tfvars`.
4. **Leverage AWS Graviton Processors**:
   This architecture defaults to AWS Graviton-based instances (`db.t4g.micro`, `db.t4g.small`, `db.r6g.large`), delivering up to **20% better price-to-performance** compared to legacy x86 instances.
5. **RDS Storage Auto Scaling**:
   Initial storage is set to 20GB (dev) and 100GB (prod) with `max_allocated_storage` enabled, preventing upfront over-provisioning fees.
