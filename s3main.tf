provider "aws" {
    region = "us-east-1"

  
}
resource "aws_s3_bucket" "my_bucket" {
    bucket = "my-unique-bucket-name-12345" # Replace with a unique bucket name
    acl   = "private"

    tags = {
        Name        = "MyBucket"
        Environment = "Dev"
    }
}
#adding object to s3 bucket
resource "aws_s3_bucket_object" "my_object" {
    bucket = "aws_s3_bucket.my_bucket.id"
    key    = "myfile.txt"
    source = "myfile.txt"   

    etag   = filemd5("./myfile.txt")
}    