resource "aws_vpc" "my_vpc" {
cidr_block = "10.0.0.0/16"
 
  tags = {
    Name = "MyVPC"
  }
}
 
resource "aws_subnet" "my_subnet" {
vpc_id = aws_vpc.my_vpc.id
cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Change this to your desired availability zone
 
  tags = {
    Name = "MySubnet"
  }
}
 
resource "aws_internet_gateway" "my_internet_gateway" {
vpc_id = aws_vpc.my_vpc.id
 
  tags = {
    Name = "MyInternetGateway"
  }
}
 
resource "aws_route_table" "my_route_table" {
vpc_id = aws_vpc.my_vpc.id
 
  tags = {
    Name = "MyRouteTable"
  }
}
 
resource "aws_route" "my_route" {
route_table_id = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.my_internet_gateway.id
}
 
resource "aws_route_table_association" "my_route_table_association" {
subnet_id = aws_subnet.my_subnet.id
route_table_id = aws_route_table.my_route_table.id
}
 
resource "aws_security_group" "my_security_group" {
vpc_id = aws_vpc.my_vpc.id
 
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = {
    Name = "MySecurityGroup"
  }
}
 
resource "aws_instance" "my_ec2_instance" {
  ami                    = "ami-0c55b159cbfafe1f0" # Change this to your desired AMI ID
  instance_type          = "t2.micro"
  key_name               = "your-key-pair-name" # Change this to your key pair name
vpc_security_group_ids = [aws_security_group.my_security_group.id]
subnet_id = aws_subnet.my_subnet.id
 
  tags = {
    Name = "MyEC2Instance"
  }
 
  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    encrypted             = false
  }
}
 
resource "aws_s3_bucket" "my_unsecure_bucket" {
  bucket = "my-unsecure-bucket-12345" # Change this to a unique bucket name
  acl    = "public-read"
}
 
resource "aws_db_instance" "my_rds_instance" {
  allocated_storage    = 20
  instance_class       = "db.t2.micro"
  engine               = "mysql"
  engine_version       = "5.7"
  name                 = "mydatabase"
  username             = "admin"
  password             = "Password1234!" # Insecure password
  publicly_accessible  = true
vpc_security_group_ids = [aws_security_group.my_security_group.id]
  skip_final_snapshot  = true
}
 
resource "aws_cloudfront_origin_access_identity" "my_origin_access_identity" {
  comment = "OAI for my S3 bucket"
}
 
resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name = aws_s3_bucket.my_unsecure_bucket.bucket_regional_domain_name
    origin_id   = "myS3Origin"
 
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.my_origin_access_identity.cloudfront_access_identity_path
    }
  }
 
  enabled = true
 
  default_cache_behavior {
    target_origin_id       = "myS3Origin"
    viewer_protocol_policy = "allow-all"
 
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
 
    forwarded_values {
      query_string = false
 
      cookies {
        forward = "none"
      }
    }
  }
 
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
 
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
resource "aws_iam_role" "my_insecure_role" {
  name = "MyInsecureRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  inline_policy {
    name = "InsecurePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = "*"
          Resource = "*"
        }
      ]
    })
  }
}
resource "aws_iam_user" "my_unsecure_user" {
  name = "my-unsecure-user"
  inline_policy {
    name = "UserPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = "*"
          Resource = "*"
        }
      ]
    })
  }
  login_profile {
    password = "Password1234!" # Insecure password policy
  }
}
resource "aws_iam_access_key" "my_iam_access_key" {
user = aws_iam_user.my_unsecure_user.name
}