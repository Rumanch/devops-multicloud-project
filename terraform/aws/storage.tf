resource "aws_s3_bucket" "devops_bucket" {
  bucket = "devops-multicloud-project-bucket-unique-ruman-1" # Make sure this is unique

  tags = {
    Name        = "devops-multicloud-bucket"
    Environment = "dev"
  }
}

# These separate resources replace the 'acl' line
resource "aws_s3_bucket_ownership_controls" "devops_bucket_oc" {
  bucket = aws_s3_bucket.devops_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "devops_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.devops_bucket_oc]
  bucket     = aws_s3_bucket.devops_bucket.id
  acl        = "private"
}
