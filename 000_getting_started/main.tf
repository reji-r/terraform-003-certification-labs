terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
 
  cloud {
    hostname = "app.terraform.io"
    organization = "cloud-dragons"

    workspaces {
      name = "getting-started"
    }
  }
}

locals {
  project_name = "Reji"
}