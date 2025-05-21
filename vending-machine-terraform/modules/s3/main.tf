data "aws_s3_bucket" "main" {
  bucket = var.bucket_name
}

data "aws_dynamodb_table" "terraform_lock" {
  name = "terraform-lock"
}