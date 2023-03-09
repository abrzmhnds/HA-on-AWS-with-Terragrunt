# AMI
data "aws_ami" "std_ami" {
  most_recent = true
  owners      = [var.ami.owners]

  filter {
    name   = "name"
    values = [var.ami.name]
  }

  filter {
    name   = "root-device-type"
    values = [var.ami.root-device-type]
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami.virtualization-type]
  }
}

# SG
resource "aws_security_group" "terraformSG" {
  name        = "allow ec2"
  description = "Allow ec2 inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "PING from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "PING from anywhere"
    from_port   = var.aws_sg.ec2_icmp_port
    to_port     = var.aws_sg.ec2_icmp_port
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = var.aws_sg.ec2_http_port
    to_port     = var.aws_sg.ec2_http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All all outbound traffic"
    from_port   = var.aws_sg.ec2_egress_port
    to_port     = var.aws_sg.ec2_egress_port
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_key_pair" "ec2-example-ssh-key" {
  key_name   = "ec2-example-ssh-key"
  public_key = "${file(var.public_key_file)}"
}

# Launch Template
resource "aws_launch_template" "terraformLT" {
  name            = "terraformLT"
  description     = "Launch template used for provisioning with Terraform"
  image_id        = data.aws_ami.std_ami.id
  instance_type   = var.aws_launch_template_instance_type
  key_name = "${aws_key_pair.ec2-example-ssh-key.key_name}"
  user_data       = filebase64("${path.module}/lib/httpd.sh")
  network_interfaces {
    security_groups = [aws_security_group.terraformSG.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "terraformInstance"
    }
  }
}

# Listener
resource "aws_alb_listener" "terraformALBListener" {
  load_balancer_arn = var.aws_alb_listener.load_balancer_arn
  port              = var.aws_alb_listener.port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraformTG.arn
  }
}

# ASG
resource "aws_autoscaling_group" "terraformASG" {
  name                = "terraformASG"
  # vpc_zone_identifier = var.aws_autoscaling_group.vpc_private_subnets_ids
  vpc_zone_identifier = var.aws_autoscaling_group.vpc_public_subnets_ids
  desired_capacity    = var.aws_autoscaling_group.desired_capacity
  max_size            = var.aws_autoscaling_group.max_size
  min_size            = var.aws_autoscaling_group.min_size
  target_group_arns    = [aws_lb_target_group.terraformTG.arn]

  launch_template {
    id      = aws_launch_template.terraformLT.id
    version = "$Latest"
  }
}

resource "aws_lb_target_group" "terraformTG" {
  health_check {
    interval            = 20
    path                = "/"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
  name        = "terraformTG"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.terraformASG.id
  alb_target_group_arn   = aws_lb_target_group.terraformTG.arn
}
