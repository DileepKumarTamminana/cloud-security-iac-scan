##############################################################################
# INTENTIONALLY INSECURE - FOR SCANNING DEMO ONLY
#
# This file contains deliberate misconfigurations so Checkov and tfsec have
# something to flag. DO NOT deploy this configuration.
##############################################################################

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ---------------------------------------------------------------------------
# ISSUE 1 & 2 & 5: public-read S3 bucket, no encryption, no versioning
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "data" {
  bucket = "dkt-demo-insecure-bucket"
}

# ISSUE 1: public-read ACL exposes objects to the world
resource "aws_s3_bucket_acl" "data" {
  bucket = aws_s3_bucket.data.id
  acl    = "public-read"
}

# (No aws_s3_bucket_server_side_encryption_configuration -> ISSUE 2: unencrypted)
# (No aws_s3_bucket_versioning                            -> ISSUE 5: no versioning)
# (No aws_s3_bucket_public_access_block                   -> ISSUE 1: not blocked)

# ---------------------------------------------------------------------------
# ISSUE 3: security group open to the entire internet on SSH (22)
# ---------------------------------------------------------------------------
resource "aws_security_group" "ssh" {
  name        = "dkt-demo-insecure-ssh"
  description = "Allows SSH from anywhere (insecure)"

  ingress {
    description = "SSH from the world"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ISSUE 3
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------------------------
# ISSUE 4: unencrypted EBS volume
# ---------------------------------------------------------------------------
resource "aws_ebs_volume" "data" {
  availability_zone = "us-east-1a"
  size              = 8
  encrypted         = false # ISSUE 4
}
