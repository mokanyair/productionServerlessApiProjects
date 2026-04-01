provider "aws" {
  region = "us-east-1"
}

assume_role_with_web_identity {
    role_arn = "arn:aws:iam::084047255080:role/TerraformDeploymentRole"
  }
}
