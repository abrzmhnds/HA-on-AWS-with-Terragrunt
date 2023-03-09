include {
  path = find_in_parent_folders()
}
terraform {
  source = "../../../../modules//vpc"
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
    arguments = [
    ]
  }
}
inputs = {
  vpc_subnet_module = {
    name = "vpc-ap-southeast"
    cidr_block = "172.0.0.0/16"
    azs                   = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
    private_subnets       = ["172.0.1.0/24", "172.0.2.0/24", "172.0.3.0/24"]
    public_subnets        = ["172.0.101.0/24", "172.0.102.0/24", "172.0.103.0/24"]
    enable_ipv6           = false
    enable_nat_gateway    = true
    enable_vpn_gateway    = false
    enable_dns_hostnames  = true
    enable_dns_support    = true
  }
}