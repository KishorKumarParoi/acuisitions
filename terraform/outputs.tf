# ============================================
# EKS CLUSTER OUTPUTS
# ============================================

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_version" {
  description = "EKS cluster version"
  value       = aws_eks_cluster.main.version
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "eks_cluster_certificate_authority" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "configure_kubectl" {
  description = "Configure kubectl command"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

# ============================================
# EKS NODE GROUP OUTPUTS
# ============================================

output "eks_node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.main[*].id
}

output "eks_node_group_status" {
  description = "EKS node group status"
  value       = aws_eks_node_group.main[*].status
}

output "eks_node_group_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = aws_iam_role.eks_node_group_role.arn
}

output "eks_node_group_asg_names" {
  description = "Auto Scaling Group names for node groups"
  value       = aws_eks_node_group.main[*].resources[0].autoscaling_groups[0].name
}

output "eks_node_count" {
  description = "Desired number of nodes in EKS node group"
  value       = var.node_desired_size
}

# ============================================
# ECR OUTPUTS
# ============================================

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.main.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.main.arn
}

output "ecr_registry_id" {
  description = "ECR registry ID (AWS Account ID)"
  value       = aws_ecr_repository.main.registry_id
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.main.name
}

output "ecr_login_command" {
  description = "Command to login to ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.repository_url}"
}

output "push_image_command" {
  description = "Example command to push Docker image to ECR"
  value       = "docker tag acquisitions:latest ${aws_ecr_repository.main.repository_url}:latest && docker push ${aws_ecr_repository.main.repository_url}:latest"
}

# ============================================
# VPC & NETWORKING OUTPUTS
# ============================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = aws_vpc.main.arn
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

# ============================================
# PUBLIC SUBNET OUTPUTS
# ============================================

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidr_blocks" {
  description = "Public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_azs" {
  description = "Availability zones for public subnets"
  value       = aws_subnet.public[*].availability_zone
}

output "public_subnet_details" {
  description = "Detailed information about public subnets"
  value = [
    for subnet in aws_subnet.public : {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
      route_table_id    = subnet.route_table_id
    }
  ]
}

# ============================================
# PRIVATE SUBNET OUTPUTS
# ============================================

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidr_blocks" {
  description = "Private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_azs" {
  description = "Availability zones for private subnets"
  value       = aws_subnet.private[*].availability_zone
}

output "private_subnet_details" {
  description = "Detailed information about private subnets"
  value = [
    for subnet in aws_subnet.private : {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
      route_table_id    = subnet.route_table_id
    }
  ]
}

# ============================================
# LOAD BALANCER OUTPUTS
# ============================================

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = try(aws_lb.main[0].dns_name, "")
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = try(aws_lb.main[0].arn, "")
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = try(aws_lb.main[0].zone_id, "")
}

output "alb_url" {
  description = "URL to access the application through ALB"
  value       = try("http://${aws_lb.main[0].dns_name}", "")
}

# ============================================
# TARGET GROUP OUTPUTS
# ============================================

output "target_group_arn" {
  description = "ARN of the target group"
  value       = try(aws_lb_target_group.main[0].arn, "")
}

output "target_group_name" {
  description = "Name of the target group"
  value       = try(aws_lb_target_group.main[0].name, "")
}

output "target_group_port" {
  description = "Port of the target group"
  value       = try(aws_lb_target_group.main[0].port, "")
}

# ============================================
# SECURITY GROUP OUTPUTS
# ============================================

output "eks_cluster_security_group_id" {
  description = "Security group ID for EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "eks_node_security_group_id" {
  description = "Security group ID for EKS nodes"
  value       = aws_security_group.eks_nodes.id
}

output "alb_security_group_id" {
  description = "Security group ID for ALB"
  value       = try(aws_security_group.alb[0].id, "")
}

output "app_security_group_id" {
  description = "Security group ID for application"
  value       = try(aws_security_group.app[0].id, "")
}

output "security_groups_details" {
  description = "Detailed security group information"
  value = {
    eks_cluster = {
      id   = aws_security_group.eks_cluster.id
      name = aws_security_group.eks_cluster.name
    }
    eks_nodes = {
      id   = aws_security_group.eks_nodes.id
      name = aws_security_group.eks_nodes.name
    }
  }
}

# ============================================
# ROUTE TABLE OUTPUTS
# ============================================

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public[0].id
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = aws_route_table.private[*].id
}

# ============================================
# NAT GATEWAY OUTPUTS
# ============================================

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = try(aws_nat_gateway.main[*].id, [])
}

output "nat_gateway_public_ips" {
  description = "Public IPs of NAT Gateways"
  value       = try(aws_eip.nat[*].public_ip, [])
}

# ============================================
# RDS OUTPUTS (if applicable)
# ============================================

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = try(aws_db_instance.main[0].endpoint, "")
}

output "rds_instance_id" {
  description = "RDS instance identifier"
  value       = try(aws_db_instance.main[0].identifier, "")
}

output "rds_database_name" {
  description = "RDS database name"
  value       = try(aws_db_instance.main[0].db_name, "")
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = try(aws_security_group.rds[0].id, "")
}

# ============================================
# ELASTICACHE OUTPUTS (if applicable)
# ============================================

output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = try(aws_elasticache_cluster.main[0].cache_nodes[0].address, "")
}

output "redis_port" {
  description = "Redis cluster port"
  value       = try(aws_elasticache_cluster.main[0].port, "")
}

output "redis_security_group_id" {
  description = "Redis security group ID"
  value       = try(aws_security_group.redis[0].id, "")
}

# ============================================
# IAM ROLE OUTPUTS
# ============================================

output "eks_cluster_role_name" {
  description = "EKS cluster IAM role name"
  value       = aws_iam_role.eks_cluster_role.name
}

output "eks_node_group_role_name" {
  description = "EKS node group IAM role name"
  value       = aws_iam_role.eks_node_group_role.name
}

output "iam_roles" {
  description = "All IAM role information"
  value = {
    eks_cluster = {
      name = aws_iam_role.eks_cluster_role.name
      arn  = aws_iam_role.eks_cluster_role.arn
    }
    eks_nodes = {
      name = aws_iam_role.eks_node_group_role.name
      arn  = aws_iam_role.eks_node_group_role.arn
    }
  }
}

# ============================================
# S3 BUCKET OUTPUTS (if applicable)
# ============================================

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = try(aws_s3_bucket.main[0].id, "")
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = try(aws_s3_bucket.main[0].arn, "")
}

# ============================================
# CLOUDWATCH OUTPUTS
# ============================================

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for EKS"
  value       = try(aws_cloudwatch_log_group.eks[0].name, "")
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = try(aws_cloudwatch_log_group.eks[0].arn, "")
}

# ============================================
# KUBERNETES CONFIGURATION
# ============================================

output "kubernetes_config" {
  description = "Kubernetes cluster configuration"
  value = {
    cluster_name   = aws_eks_cluster.main.name
    endpoint       = aws_eks_cluster.main.endpoint
    ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    region         = var.aws_region
  }
  sensitive = true
}

output "kubectl_config_commands" {
  description = "Commands to configure kubectl"
  value = {
    update_kubeconfig = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
    get_token         = "aws eks get-token --cluster-name ${aws_eks_cluster.main.name} --region ${var.aws_region}"
    get_pods          = "kubectl get pods --all-namespaces"
    get_nodes         = "kubectl get nodes -o wide"
  }
}

# ============================================
# DOCKER & ECR COMMANDS
# ============================================

output "docker_commands" {
  description = "Docker and ECR commands"
  value = {
    login       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    build_image = "docker build -t acquisitions:latest ."
    tag_image   = "docker tag acquisitions:latest ${aws_ecr_repository.main.repository_url}:latest"
    push_image  = "docker push ${aws_ecr_repository.main.repository_url}:latest"
    pull_image  = "docker pull ${aws_ecr_repository.main.repository_url}:latest"
  }
}

# ============================================
# DEPLOYMENT SUMMARY
# ============================================

output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    environment           = var.environment
    region                = var.aws_region
    vpc_id                = aws_vpc.main.id
    eks_cluster_name      = aws_eks_cluster.main.name
    eks_cluster_endpoint  = aws_eks_cluster.main.endpoint
    ecr_repository_url    = aws_ecr_repository.main.repository_url
    alb_dns_name          = try(aws_lb.main[0].dns_name, "")
    public_subnets_count  = length(aws_subnet.public)
    private_subnets_count = length(aws_subnet.private)
    node_group_count      = length(aws_eks_node_group.main)
    node_desired_count    = var.node_desired_size
  }
}

# ============================================
# NEXT STEPS
# ============================================

output "next_steps" {
  description = "Next steps after terraform apply"
  value = {
    step_1_configure_kubectl = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
    step_2_verify_cluster    = "kubectl cluster-info && kubectl get nodes"
    step_3_login_to_ecr      = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    step_4_build_docker      = "docker build -t acquisitions:latest ."
    step_5_push_image        = "docker tag acquisitions:latest ${aws_ecr_repository.main.repository_url}:latest && docker push ${aws_ecr_repository.main.repository_url}:latest"
    step_6_deploy_to_k8s     = "kubectl apply -f k8s-deployment.yaml"
  }
}

# ============================================
# CONNECTION STRINGS (Sensitive)
# ============================================

output "connection_strings" {
  description = "Connection strings for databases and services"
  value = {
    rds_postgres_url = try("postgresql://admin:password@${aws_db_instance.main[0].endpoint}/acquisitions", "")
    redis_url        = try("redis://${aws_elasticache_cluster.main[0].cache_nodes[0].address}:${aws_elasticache_cluster.main[0].port}", "")
    alb_http_url     = try("http://${aws_lb.main[0].dns_name}", "")
  }
  sensitive = true
}

# ============================================
# TERRAFORM STATE INFORMATION
# ============================================

output "terraform_version" {
  description = "Terraform version used"
  value       = terraform.version
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_caller_identity" {
  description = "AWS caller identity information"
  value = {
    account_id = data.aws_caller_identity.current.account_id
    user_arn   = data.aws_caller_identity.current.arn
  }
}

# ============================================
# COST ESTIMATION
# ============================================

output "cost_estimation" {
  description = "Estimated monthly costs (for reference only)"
  value = {
    eks_cluster = "~$0.10/hour + data transfer costs"
    nat_gateway = "~$0.045/hour per NAT Gateway + $0.045/GB processed"
    alb         = "~$0.0225/hour + $0.006/LCU"
    ecr         = "$0.10 per GB stored"
    rds         = "Check RDS pricing based on instance type"
    elasticache = "Check ElastiCache pricing based on node type"
    total_note  = "Use AWS Cost Calculator: https://calculator.aws"
  }
}
