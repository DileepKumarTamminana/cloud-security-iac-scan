##############################################################################
# REMEDIATED CONFIGURATION
#
# The same resources as insecure/main.tf, hardened to pass Checkov/tfsec
# best-practice checks. Provided as the "after" side of the comparison.
##############################################################################

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.57"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "allowed_ssh_cidr" {
  description = "CIDR range permitted to reach SSH. Defaults to a private range."
  type        = string
  default     = "10.0.0.0/16"
}

# ---------------------------------------------------------------------------
# FIX 1/2/5: private, encrypted, versioned S3 bucket with public access blocked
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "data" {
  bucket = "dkt-demo-secure-bucket"
}

resource "aws_s3_bucket_acl" "data" {
  bucket = aws_s3_bucket.data.id
  acl    = "private" # FIX 1
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true # FIX 1
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # FIX 2
    }
  }
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled" # FIX 5
  }
}

# ---------------------------------------------------------------------------
# FIX 3: SSH restricted to an explicit, non-public CIDR
# ---------------------------------------------------------------------------
resource "aws_security_group" "ssh" {
  name        = "dkt-demo-secure-ssh"
  description = "Allows SSH only from an approved CIDR range"

  ingress {
    description = "SSH from approved network only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr] # FIX 3
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------------------------
# FIX 4: encrypted EBS volume
# ---------------------------------------------------------------------------
resource "aws_ebs_volume" "data" {
  availability_zone = "us-east-1a"
  size              = 8
  encrypted         = true # FIX 4
}
