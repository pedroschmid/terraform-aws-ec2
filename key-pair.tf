resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "ec2-key-pair"
  public_key = tls_private_key.this.public_key_openssh
}