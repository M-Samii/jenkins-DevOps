terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-samy-lock"
    region         = "us-east-1"
    key            = "jenkins_project/terraform.tfstate"
    dynamodb_table = "terraform-locks"   # Optional, but recommended for locking
    encrypt        = true
    
  }
}
