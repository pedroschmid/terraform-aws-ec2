resource "aws_alb" "this" {
  name               = "terraform-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public.*.id
}

resource "aws_lb_target_group" "this" {
  name     = "terraform-alb-tg"
  protocol = "HTTP"
  port     = 80
  vpc_id   = aws_vpc.this.id


  health_check {
    protocol = "HTTP"
    port     = 80
    timeout  = 3
    interval = 10
  }
}

resource "aws_lb_target_group_attachment" "nginx" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.nginx.id
  port             = 80
}

resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  protocol          = "HTTP"
  port              = 80
  depends_on        = [aws_lb_target_group.this]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}