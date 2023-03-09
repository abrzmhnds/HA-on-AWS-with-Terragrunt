include {
  path = find_in_parent_folders()
}
terraform {
  source = "../../../../modules//alb"
extra_arguments "init_args" {
    commands = [
      "init"
    ]
arguments = [
    ]
  }
}
dependency "vpc" {
  config_path = "../vpc"
}
inputs = {
  aws_security_group_http = {
    name        = "http-alb-sg"
    description = "http for ALB"
    vpc_id      = dependency.vpc.outputs.vpc_id
    from_port = 80
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  aws_security_group_egress_all = {
    name        = "egress-all"
    description = "Allow all outbound traffic"
    vpc_id      = dependency.vpc.outputs.vpc_id
  }
  alb = {
    name               = "terragrunt-alb"
    internal           = false
    load_balancer_type = "application"
    subnets            = dependency.vpc.outputs.vpc_public_subnets_ids
  }
  aws_lb_target_group = {
    aws_lb_target_group    = 80
    vpc_id                 = dependency.vpc.outputs.vpc_id
  }
  external_lb_listener_arn = {
    port           = 80
  }
tags = {
    Name        = "external-lb-security-group"
  }
}