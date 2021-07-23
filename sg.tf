resource "aws_security_group" "ec2" {
  name        = "terraform-ec2-sg"
  description = "Allow inboud access to the Application task from NGINX"
  vpc_id      = aws_vpc.this.id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}