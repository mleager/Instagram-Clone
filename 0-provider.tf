terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.12.1"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-east-1"
}

provider "mongodbatlas" {}

# provider "mongodbatlas" {
#   description = "Set Public & Private API Key as ENV Variables."
#   note        = "Use space before 'export' and use double-quotes for the values."

#   public_key  = " export MONGODB_ATLAS_PUBLIC_KEY='xxxx'"
#   private_key = " export MONGODB_ATLAS_PRIVATE_KEY='xxxx'"
# }
