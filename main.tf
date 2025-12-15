terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# The provider block configures the AWS provider with a specific region
provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "myserv" {
  ami = #add AMI ID here "ami-0c55b159cbfafe1f0" # Example AMI ID
  instance_type = #add instance type here "t2.micro" # Example instance type
  tags = {
    Name = "MyServer"
  })
}