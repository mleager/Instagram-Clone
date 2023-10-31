variable "project" {
  type        = string
  description = "Name of the Terraform Project"
}

variable "use_amazonlinux" {
  type        = bool
  description = "Set to 'True' to use Amazon Linux 2023 AMI, or 'False' for Ubuntu 22.04 AMI"
  default     = true
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance type for ASG"
}

variable "dns_server_name" {
  type        = string
  description = "Domain address of your DNS - necessary if using HTTPS. For HTTP, use Public ALB DNS name."
}

variable "mongodbatlas_public_key" {
  type        = string
  description = "Public API Key for MongoDB Atlas"
  sensitive   = true
}

variable "mongodbatlas_private_key" {
  type        = string
  description = "Private API Key for MongoDB Atlas"
  sensitive   = true
}

variable "org_id" {
  type        = string
  description = "MongoDB Organization ID"
}

variable "db_project_name" {
  type        = string
  description = "The MongoDB Atlas Project Name"
}

variable "cluster_name" {
  type        = string
  description = "The MongoDB Atlas Cluster Name"
}

variable "cloud_provider" {
  type        = string
  description = "The cloud provider to use, must be AWS, GCP or AZURE"
}

variable "db_region" {
  type        = string
  description = "MongoDB Atlas Cluster Region, must be a region for the provider given"
}

variable "mongodbversion" {
  type        = string
  description = "The Major MongoDB Version"
}

variable "dbuser" {
  type        = string
  description = "MongoDB Atlas Database User Name"
}

variable "dbuser_password" {
  type        = string
  description = "MongoDB Atlas Database User Password"
  sensitive   = true
}

variable "database_name" {
  type        = string
  description = "The database in the cluster to limit the database user to, the database does not have to exist yet"
}

variable "access_list_ip" {
  type        = string
  description = "The IP Address that the cluster will be accessed from, can also be a CIDR Range or AWS security group"
}

variable "access_list_cidr" {
  type        = string
  description = "The CIDR range that the cluster will be accessed from, can also be an IP Address or AWS security group"
}

variable "postmark_api" {
  type        = string
  description = "API Key for Postmark"
  sensitive   = true
}

variable "user_email" {
  type        = string
  description = "Email address to send notifications from, such as Password Reset Template"
}

variable "bucket_name" {
  type        = string
  description = "Name of the AWS S3 Bucket to use for the project"
}

variable "bucket_region" {
  type        = string
  description = "Region to deploy AWS S3 Bucket"
}

variable "iam_user_key" {
  type        = string
  description = "AWS IAM User Key"
  sensitive   = true
}

variable "iam_user_secret_key" {
  type        = string
  description = "AWS IAM User Secret Key"
  sensitive   = true
}
