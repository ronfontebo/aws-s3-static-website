# This is a terraform manifest for setting up the aws s3 environment:
#===================================================================
# Steps:
#=======
# Register a custom domain with Route 53
# Create 3 buckets
# Create root domain bucket, enable vesrioning and configure logging
# Configure root domain bucket for static website hosting
# Create logging bucket to store logging data of all web traffic going to root domain bucket
# Configure root domain bucket policy
# Create subdomain bucket for redirecting traffic to root domain bucket
# Upload index document and website content
# Upload an error document
# Edit S3 Block Public Access settings
# Attach a bucket policy
# Test your domain endpoint
# Add alias records for your domain and subdomain
# Test the website
# Speeding up your website with Amazon CloudFront
#-------------------------------------------------------------------------------------------------------------



# Configure terraform provider as aws  # add an s3 backend for state storage  ***advanced
#-------------------------------------------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.9.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region = "us-east-2"
}



# Create root domain bucket, enable versioning and configure logging
#-------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "root_domain" {
  bucket = "${var.root_domain}"
  acl    = "public-read"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.root_log_bucket.id}"
    target_prefix = "log/"
  }
}



# Configure root domain bucket for static website hosting
#-------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_website_configuration" "root_domain" {
  bucket = "${aws_s3_bucket.root_domain.id}"

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}



# Create logging bucket to store logging data of all web traffic going to root domain bucket
#-------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "root_log_bucket" {
  bucket = "${var.root_domain}-logs"
  acl    = "log-delivery-write"
}



# Configure root domain bucket to allow public access
#-------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "root_domain" {
  bucket = "${aws_s3_bucket.root_domain.id}"

  block_public_acls   = false
  block_public_policy = false
}



# Configure root domain bucket policy to allow "s3:ListBucket" and "s3:GetObject" permissions
#-------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "root_domain" {
  bucket = "${aws_s3_bucket.root_domain.id}"
  policy = "${data.aws_iam_policy_document.root_domain_public_access.json}"
}

data "aws_iam_policy_document" "root_domain_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.root_domain.arn}/*"]     
  }

  statement {
    principals {
      type = "AWS"
      identifiers = ["*"]

    }
    actions = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.root_domain.arn}/*"]
  }
}



# Create subdomain bucket and configure website redirect
#-------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "subdomain" {
  bucket = "www.${var.root_domain}"

  website { 
    redirect_all_requests_to {
      host_name = "${var.root_domain}""
      protocol  = "http"
}


#*************************************************************************************************************
#                                    End of s3 environment setup!!
#*************************************************************************************************************
