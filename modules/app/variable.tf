# AMI
variable "ami" {
  type = object({
    owners                = string
    name                  = string
    root-device-type      = string
    virtualization-type   = string
  })
}

# VPC
variable "vpc_id" {
  type        = string
}

# SG
variable "aws_sg" {
  type = object({
    ec2_icmp_port   = number
    ec2_http_port   = number
    ec2_egress_port = number
  })
}

variable "public_key_file" {
  description = "Public key file for EC2 instance login"
  default     = "ec2-example-ssh-key.pub"
}

# Launch Template
variable "aws_launch_template_instance_type" {
  type        = string
}

# Target Group
# variable "aws_lb_target_group" {
#   type        = number
# }

# Listener
variable "aws_alb_listener" {
  type = object({
    load_balancer_arn        = string
    port                     = number
  })
}

# ASG
# variable "vpc_public_subnet_ids" {
#   type        = list(string)
# }
variable "aws_autoscaling_group" {
  type = object({
    # vpc_private_subnets_ids = list(string)
    vpc_public_subnets_ids = list(string)
    desired_capacity  = number
    max_size          = number
    min_size          = number
  })
}