terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.70"
    }
  }
}

provider "aws" {
  region = var.region

  # every resource Terraform creates gets these tags, so it's easy to find (and confirm it's gone)
  default_tags {
    tags = {
      Project   = var.cluster_name
      ManagedBy = "terraform"
    }
  }
}
