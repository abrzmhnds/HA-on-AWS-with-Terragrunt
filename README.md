# Terragrunt on AWS
Deploy High Avaibility App on AWS with Terragrunt

## Requirement
- Terraform
- Terragrunt

## Content
- Folder Structure
- Setup AWS Profile
- Run Project

### Folder Structure
- Folder structure:


    ```bash
    ├── README.md
    ├── environment
    │   └── ap-southeast-1
    │       ├── infra
    │       │   ├── load-balancer
    │       │   │   └── terragrunt.hcl
    │       │   └── vpc
    │       │       └── terragrunt.hcl
    │       └── services
    │           └── web-server
    │               └── terragrunt.hcl
    └── modules
        ├── alb
        │   ├── main.tf
        │   ├── output.tf
        │   └── variable.tf
        ├── app
        │   ├── main.tf
        │   ├── output.tf
        │   └── variable.tf
        └── vpc
            ├── main.tf
            ├── output.tf
            └── variable.tf
    ```
- The project has two main folder which is environment and modules
- Environment is folder where you store terragrunt.hcl file. Terragrunt.hcl will call terraform from modules folder. In terragrunt.hcl you will input every variable that suits with your environtment. This is example input variable in terragrunt.hcl file on web-server folder

```
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
```

- And then modules folder is where you store the terraform file. This module will not be modified. All change will be made in terragrunt
- In case you will expand your environment become two region, folder structure will be like this

```
    ├── README.md
    ├── environment
    │   ├── ap-southeast-1
    │   │   ├── infra
    │   │   │   ├── load-balancer
    │   │   │   │   └── terragrunt.hcl
    │   │   │   └── vpc
    │   │   │       └── terragrunt.hcl
    │   │   └── services
    │   │       └── web-server
    │   │           └── terragrunt.hcl
    │   └── us-weast-1
    │       ├── infra
    │       │   ├── load-balancer
    │       │   │   └── terragrunt.hcl
    │       │   └── vpc
    │       │       └── terragrunt.hcl
    │       └── services
    │           └── web-server
    │               └── terragrunt.hcl
    └── modules
        ├── alb
        │   ├── main.tf
        │   ├── output.tf
        │   └── variable.tf
        ├── app
        │   ├── main.tf
        │   ├── output.tf
        │   └── variable.tf
        └── vpc
            ├── main.tf
            ├── output.tf
            └── variable.tf
```

### Setup AWS Profile
In parent directory, change several variable in terragrunt.hcl file
```
provider "aws" {
  region = var.aws_region
  shared_credentials_file = "/Users/your-username/.aws/credentials" # aws credential directory
  profile = "terra"
}
variable "aws_region" {
  default  = "ap-southeast-1" # change region with your requirement
}
```
Fill credential in /Users/your-username/.aws/credentials
```
[terra]
aws_access_key_id = your_aws_access_key_id
aws_secret_access_key = your_aws_secret_access_key
```

### Run Project
Create ssh key for vm
```
cd modules/app/
ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (~/.ssh/id_rsa): ec2-example-ssh-key
```
Back into root Directory and Apply Code to Deploy
```
terragrunt run-all apply
```
Open load balancer dns name, and then refresh repeatedly for test the load balancer. The output should be like this
![alb](/img/Screenshot 2023-03-08 152015.png)
![alb](/img/Screenshot 2023-03-08 152103.png)
Destroy All
```
terragrunt run-all destroy
```

## Ref
- https://blog.devgenius.io/an-introduction-to-terragrunt-dfe9921f5e48
- https://itnext.io/creating-an-ecs-fargate-service-for-container-applications-using-terraform-and-terragrunt-2af5db3b35c0