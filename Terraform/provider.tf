terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.22.0"
    }
  }
}

provider "aws" {
  region     = "us-west-2"
  access_key = "AKIA3Z4UFVAMP2CESRE6"
  secret_key = "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"
}