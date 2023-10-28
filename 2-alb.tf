module "public_alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 5.0.0"

  name        = "public-alb-sg"
  description = "Security group to allow incoming HTTP and all outgoing traffic from Public ALB."
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow all outgoing traffic from Public ALB."
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "private_alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 5.0.0"

  name        = "private-alb-sg"
  description = "Security group to allow incoming HTTP and all outgoing traffic from Private ALB."
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 4000
      to_port                  = 4000
      protocol                 = "tcp"
      source_security_group_id = module.frontend_sg.security_group_id
      description              = "Allow incoming traffic from Frontend SG on Port 4000"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow all outgoing traffic from Internal ALB."
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "public_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.project}-alb-public"

  load_balancer_type = "application"

  create_security_group = false

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.public_alb_sg.security_group_id]

  target_groups = [
    {
      name_prefix      = "front-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "3000"
        healthy_threshold   = 2
        unhealthy_threshold = 8
        timeout             = 15
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  # https_listeners = [
  #   {
  #     port               = 443
  #     protocol           = "HTTPS"
  #     certificate_arn    = ""
  #     target_group_index = 0
  #   }
  # ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Project = "${var.project}"
    Group   = "public"
  }
}

module "private_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.project}-alb-private"

  internal           = true
  load_balancer_type = "application"

  create_security_group = false

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  security_groups = [module.private_alb_sg.security_group_id]

  target_groups = [
    {
      name_prefix      = "back-"
      backend_protocol = "HTTP"
      backend_port     = 4000
      target_type      = "instance"

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 8
        timeout             = 15
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  # https_listeners = [
  #   {
  #     port               = 443
  #     protocol           = "HTTPS"
  #     certificate_arn    = ""
  #     target_group_index = 0
  #   }
  # ]

  http_tcp_listeners = [
    {
      port               = 4000
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Project = "${var.project}"
    Group   = "private"
  }
}
