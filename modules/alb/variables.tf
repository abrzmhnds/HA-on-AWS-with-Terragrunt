variable "aws_security_group_http" {
  type = object({
    name        = string
    description = string
    vpc_id      = string
    from_port   = number
    to_port     = number
    cidr_blocks = list(string)
  })
}

variable "aws_security_group_egress_all" {
  type = object({
    name        = string
    description = string
    vpc_id      = string
  })
}

variable "alb" {
  type = object({
    name               = string
    internal           = bool
    load_balancer_type = string
    subnets            = list(string)
  })
}


