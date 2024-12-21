# ALB #

resource "aws_lb" "threat-alb" {
  name               = "threat-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.threat-sg.id] 
  subnets            = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id]

  tags = { 
    Name = "threat-alb"
  }
}

resource "aws_lb_listener" "threat-lb-http" {
  load_balancer_arn = aws_lb.threat-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "threat-lb-https" {
  load_balancer_arn = aws_lb.threat-alb.arn
  certificate_arn   = "arn:aws:acm:eu-west-2:872515255126:certificate/38f3aa96-29ed-4946-a03a-0a9e15bf5350"
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.threat-fargate.arn
      }
    }
  }

}

resource "aws_lb_target_group" "threat-fargate" {
  vpc_id      = aws_vpc.main-vpc.id 
  name        = "threat-app-fargate"
  protocol    = "HTTP"
  port        = "3000"
  target_type = "ip"

  health_check {
    path = "/"
    port = "traffic-port"
  }
}