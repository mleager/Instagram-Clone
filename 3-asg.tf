data "aws_ami" "amazonlinux2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

locals {
  amazonlinux2023_id = data.aws_ami.amazonlinux2023.id
  ubuntu_id          = data.aws_ami.ubuntu.id
}

module "frontend_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 5.0.0"

  name        = "frontend-sg"
  description = "Allow incoming HTTP traffic from Public ALB."
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.public_alb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow all outbound traffic from Frontend ASG."
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "backend_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 5.0.0"

  name        = "backend-sg"
  description = "Allow incoming HTTP traffic from Internal ALB."
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 4000
      to_port                  = 4000
      protocol                 = "tcp"
      source_security_group_id = module.private_alb_sg.security_group_id
      description              = "Allow incoming traffic from Internal ALB on Port 4000."
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow all outbound traffic from Backend ASG."
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "frontend_asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${var.project}-frontend-asg"

  min_size                  = 0
  max_size                  = 2
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  health_check_grace_period = 300
  vpc_zone_identifier       = module.vpc.private_subnets
  force_delete              = true

  target_group_arns = module.public_alb.target_group_arns

  create_launch_template = false
  launch_template_id     = var.use_amazonlinux ? aws_launch_template.frontend_template.id : aws_launch_template.frontend_template_ubuntu.id
  instance_name          = "frontend"
  security_groups        = [module.frontend_sg.security_group_id]

  ebs_optimized     = false
  enable_monitoring = false

  create_iam_instance_profile = true
  iam_role_name               = "${var.project}-ssm-role"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role example"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Project = "${var.project}"
    Group   = "frontend"
  }
}

module "backend_asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${var.project}-backend-asg"

  min_size                  = 0
  max_size                  = 2
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  health_check_grace_period = 300
  vpc_zone_identifier       = module.vpc.private_subnets
  force_delete              = true

  target_group_arns = module.private_alb.target_group_arns

  create_launch_template = false
  launch_template_id     = var.use_amazonlinux ? aws_launch_template.backend_template.id : aws_launch_template.backend_template_ubuntu.id
  instance_name          = "backend"
  security_groups        = [module.backend_sg.security_group_id]

  ebs_optimized     = false
  enable_monitoring = false

  create_iam_instance_profile = false
  iam_instance_profile_arn    = module.frontend_asg.iam_instance_profile_arn

  tags = {
    Project = "${var.project}"
    Group   = "backend"
  }
}
