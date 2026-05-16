resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "eks-constrained-vpc"
  }
}

resource "aws_subnet" "private_constrained_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/27"  
  availability_zone = "eu-west-1a"

  tags = {
    Name                              = "private-constrained-a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_constrained_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.32/27" 
  availability_zone = "eu-west-1b"

  tags = {
    Name                              = "private-constrained-b"
    "kubernetes.io/role/internal-elb" = "1"
  }
}