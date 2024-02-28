terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      version = "~> 5.38"
      source  = "hashicorp/aws"
    }

    awscc = {
      version = "~> 0.71"
      source  = "hashicorp/awscc"
    }
  }
}
