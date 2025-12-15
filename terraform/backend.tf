# ============================================
# TERRAFORM BACKEND CONFIGURATION
# Remote state storage in S3 with DynamoDB locking
# ============================================

terraform {
  backend "s3" {
    # S3 bucket for storing terraform.tfstate
    bucket = "acquisitions-terraform-state"

    # Path to state file within bucket
    key = "acquisitions/terraform.tfstate"

    # AWS region where S3 bucket is located
    region = "us-east-1"

    # Enable encryption at rest
    encrypt = true

    # DynamoDB table for state locking
    # Prevents concurrent modifications
    dynamodb_table = "acquisitions-terraform-locks"

    # Skip credentials validation (use IAM roles)
    skip_credentials_validation = false

    # Skip requesting account ID (use IAM roles)
    skip_region_validation = false

    # Skip metadata API check
    skip_metadata_api_check = false
  }
}

# ============================================
# CREATE S3 BUCKET (Run separately first)
# ============================================
# This resource creates the S3 bucket that will store state
# Run: terraform apply -target=aws_s3_bucket.terraform_state
# Then comment this out before running full terraform apply

resource "aws_s3_bucket" "terraform_state" {
  bucket = "acquisitions-terraform-state"

  tags = {
    Name        = "Acquisitions Terraform State"
    Environment = "production"
    Purpose     = "Terraform State Storage"
  }
}

# ============================================
# S3 BUCKET VERSIONING
# Keep history of all state file versions
# ============================================

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ============================================
# S3 BUCKET ENCRYPTION
# Encrypt state files at rest
# ============================================

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ============================================
# S3 BUCKET BLOCK PUBLIC ACCESS
# Ensure state files are never publicly accessible
# ============================================

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================
# S3 BUCKET LIFECYCLE POLICY
# Automatically delete old state versions after 90 days
# ============================================

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  rule {
    id     = "delete-incomplete-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# ============================================
# S3 BUCKET LOGGING
# Log all access to S3 bucket
# ============================================

resource "aws_s3_bucket" "terraform_state_logs" {
  bucket = "acquisitions-terraform-state-logs"

  tags = {
    Name    = "Acquisitions Terraform State Logs"
    Purpose = "S3 Access Logs"
  }
}

resource "aws_s3_bucket_logging" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  target_bucket = aws_s3_bucket.terraform_state_logs.id
  target_prefix = "state-logs/"
}

# ============================================
# DYNAMODB TABLE FOR STATE LOCKING
# Prevents concurrent modifications to state
# ============================================

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "acquisitions-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "Acquisitions Terraform Locks"
    Environment = "production"
    Purpose     = "Terraform State Locking"
  }
}

# ============================================
# IAM POLICY FOR TERRAFORM STATE ACCESS
# Grants minimum required permissions
# ============================================

resource "aws_iam_policy" "terraform_state" {
  name        = "acquisitions-terraform-state-policy"
  description = "Policy for Terraform to access S3 and DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3StateAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = aws_s3_bucket.terraform_state.arn
      },
      {
        Sid    = "S3StateFileAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.terraform_state.arn}/*"
      },
      {
        Sid    = "DynamoDBLocking"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.terraform_locks.arn
      },
      {
        Sid    = "LoggingBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.terraform_state_logs.arn}/*"
      }
    ]
  })

  tags = {
    Name = "acquisitions-terraform-state-policy"
  }
}

# ============================================
# IAM USER FOR TERRAFORM (Optional)
# Create dedicated user for CI/CD pipelines
# ============================================

resource "aws_iam_user" "terraform" {
  name = "acquisitions-terraform-user"

  tags = {
    Name    = "Acquisitions Terraform User"
    Purpose = "CI/CD Automation"
  }
}

# Attach state access policy to user
resource "aws_iam_user_policy_attachment" "terraform_state" {
  user       = aws_iam_user.terraform.name
  policy_arn = aws_iam_policy.terraform_state.arn
}

# Attach additional policies for EC2, RDS, etc.
resource "aws_iam_user_policy_attachment" "terraform_admin" {
  user       = aws_iam_user.terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  # ⚠️ WARNING: Admin access is overly permissive
  # Use specific policies in production!
}

# ============================================
# OUTPUTS FOR BACKEND SETUP
# ============================================

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "terraform_user_name" {
  description = "IAM user for Terraform CI/CD"
  value       = aws_iam_user.terraform.name
}

output "terraform_state_policy_arn" {
  description = "ARN of the Terraform state access policy"
  value       = aws_iam_policy.terraform_state.arn
}
