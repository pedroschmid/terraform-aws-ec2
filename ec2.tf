resource "aws_instance" "bastion" {
  ami                         = var.EC2_AMI
  instance_type               = var.EC2_INSTANCE_TYPE
  subnet_id                   = element(aws_subnet.public.*.id, 0)
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.ec2.key_name

  provisioner "file" {
    source      = "keys/${aws_key_pair.ec2.key_name}.pem"
    destination = "/home/ec2-user/${aws_key_pair.ec2.key_name}.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("keys/${aws_key_pair.ec2.key_name}.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = ["chmod 400 ~/${aws_key_pair.ec2.key_name}.pem"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("keys/${aws_key_pair.ec2.key_name}.pem")
      host        = self.public_ip
    }
  }

  depends_on = [
    aws_vpc.this,
    aws_internet_gateway.this
  ]

  tags = {
    "Name" = "terraform-bastion-ec2"
  }
}

resource "aws_instance" "nginx" {
  ami                         = var.EC2_AMI
  instance_type               = var.EC2_INSTANCE_TYPE
  subnet_id                   = element(aws_subnet.private.*.id, 0)
  vpc_security_group_ids      = [aws_security_group.nginx.id]
  associate_public_ip_address = false

  key_name = aws_key_pair.ec2.key_name

  user_data = file("scripts/install-nginx.sh")

  tags = {
    "Name" = "terraform-nginx-ec2"
  }
}