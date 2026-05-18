# StartTech Infrastructure Automation (IaC)

This repository contains the complete Infrastructure as Code (IaC) architecture designed for the automated provisioning, monitoring, and security isolation of the StartTech full-stack application ecosystem.

## 🛠️ Architecture Topology Layout
The network and service layout are fully modularized and structured as follows:
* **VPC & Networking:** Custom VPC (`10.0.0.0/16`) split cleanly into Public Subnets (directly routing traffic via an Internet Gateway) and Private Subnets.
* **Compute Tier:** An EC2 Auto Scaling Group (ASG) deployed directly into Public Subnets for reliable, high-availability internet access to pull image objects.
* **Traffic Management:** An Application Load Balancer (ALB) acting as the single public entry point, routing external traffic safely to the backend on port `8080`.
* **Storage & Content Delivery:** An S3 Bucket hosting the static frontend web assets, accelerated globally via a CloudFront CDN distribution layer.
* **Monitoring Matrix:** Integrated CloudWatch log streams tracking backend application telemetry outputs in real time.

## 🚀 Step-by-Step Initial Deployment Guide
To spin up this entire ecosystem from scratch using your local MacBook terminal:

1. **Configure local AWS parameters:**
   ```bash
   aws configure
   ```
2. **Initialize Terraform provider plugins and remote S3 backend:**
   ```bash
   cd terraform
   terraform init
   ```
3. **Validate and preview your infrastructure blueprints:**
   ```bash
   terraform plan
   ```
4. **Provision the live AWS cloud resources:**
   ```bash
   terraform apply -auto-approve
   ```

## 📊 Infrastructure Verification Commands
* View active cluster scaling fleets:
  ```bash
  aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].[InstanceId,LaunchTime]" --output table
  ```
* Verify Load Balancer operational state:
  ```bash
  aws elbv2 describe-load-balancers --names "starttech-backend-alb" --query "LoadBalancers[0].DNSName" --output text
  ```
