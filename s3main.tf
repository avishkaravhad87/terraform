provider "aws" {
    region = "us-east-1"

  
}
resource "aws_s3_bucket" "my_bucket" {
    bucket = "my-unique-bucket-name-12345" # Replace with a unique bucket name
    acl    = "private"

    tags = {
        Name        = "MyBucket"
        Environment = "Dev"
    }
}