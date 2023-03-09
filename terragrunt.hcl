remote_state {
  backend = "s3"
  config = {
    bucket  = "abrz-trg"
    key     = "terragrunted/${path_relative_to_include()}.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}
terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    optional_var_files = [
      "${get_terragrunt_dir()}/environment/ap-southeast-1/regional.tfvars",
    ]
  }
}
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = var.aws_region
  shared_credentials_file = "/Users/your-username/.aws/credentials" # aws credential directory
  profile = "terra"
}
variable "aws_region" {
  default  = "ap-southeast-1" # change region with your requirement
}
terraform {
  backend "s3" {
  }
}
EOF
}