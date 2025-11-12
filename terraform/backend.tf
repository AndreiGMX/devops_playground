terraform {
  backend "s3" {
    bucket = "devops-playground-terraform-tfstate"
    key    = "terraform.tfstate"
    region = "eu-north-1" # Must match the region of the S3 bucket

    # Use native S3 locking mechanism (requires Terraform 1.10.0+)
    # No DynamoDB table needed!
    use_lockfile = true
  }
}
