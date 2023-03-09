include {
  path = find_in_parent_folders()
}
terraform {
  source = "../../../../modules//app"
extra_arguments "init_args" {
    commands = [
      "init"
    ]
arguments = [
    ]
  }
}
dependency "vpc" {
  config_path = "../../infra/vpc"
}
dependency "external_alb" {
  config_path = "../../infra/load-balancer"
}
inputs = {
  # VPC
  vpc_id                  = dependency.vpc.outputs.vpc_id
  vpc_public_subnets_ids  = dependency.vpc.outputs.vpc_public_subnets_ids
  vpc_private_subnets_ids = dependency.vpc.outputs.vpc_private_subnets_ids
  # AMI
  ami = {
    owners              = "amazon"
    name                = "amzn2-ami-hvm-*-x86_64-ebs"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  # Security Group
  aws_sg = {
    vpc_id  = dependency.vpc.outputs.vpc_id
    ec2_icmp_port   = -1
    ec2_http_port   = 80
    ec2_egress_port = 0
  }
  # Launch Template
  aws_launch_template_instance_type = "t2.micro"
  vpc_id  = dependency.vpc.outputs.vpc_id
  
  # Listener
  aws_alb_listener = {
    load_balancer_arn = dependency.external_alb.outputs.load_balancer_arn
    port              = 80
  }
  # AutoScaling Group
  aws_autoscaling_group = {
    vpc_public_subnets_ids = dependency.vpc.outputs.vpc_public_subnets_ids
    desired_capacity  = 2
    max_size          = 3
    min_size          = 1
  }
}