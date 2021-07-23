resource "aws_instance" "ec2" {
  ami                         = var.EC2_AMI
  instance_type               = var.EC2_INSTANCE_TYPE
  subnet_id                   = element(aws_subnet.public.*.id, 0)
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.ec2.key_name

  depends_on = [
    aws_vpc.this,
    aws_internet_gateway.this
  ]

  tags = {
    "Name" = "terraform-public-ec2"
  }
}