
//1. create Security Group allow ssh, http, https
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Allow 22, http, https inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "public_sg"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

//2. create 2 EC2 public subnet
resource "aws_instance" "public_ec2" {
  count = length(aws_subnet.public_subnet)
  ami = var.ami 
  instance_type = var.instance_type
  key_name = "vpc-keypair"
  subnet_id = aws_subnet.public_subnet[count.index].id
  security_groups = [aws_security_group.public_sg.id]
  associate_public_ip_address = true  # Ensure instance gets a public IP
  tags = {
    Name = "EC2_Public ${count.index + 1}"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo su 
              yum update -y
              yum install -y nginx 
              systemctl start nginx 
              systemctl enable nginx

              chmod 2775 /usr/share/nqinx/html
              echo "<h1>Web Server - ${count.index + 1}</h1>" > /usr/share/nginx/html/index.html
              EOF
  
}

#3. create target group of application load balancer
resource "aws_lb_target_group" "alb_target_group" {
  name        = "alb-target-group"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "alb_target_group_attachment" {
  count            = length(aws_instance.public_ec2) 
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.public_ec2[count.index].id


}

# 4. create application load blancer
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id] //using the same sg with ec2
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  # enable_deletion_protection = true
  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert_validate.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}