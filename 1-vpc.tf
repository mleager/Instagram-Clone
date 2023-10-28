module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.0.0"

  name = "${var.project}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  map_public_ip_on_launch = true

  public_subnet_names  = ["public-subnet-1a", "public-subnet-1b"]
  private_subnet_names = ["private-subnet-1a", "private-subnet-1b"]

  vpc_tags = {
    Name = "${var.project}-vpc"
  }

  igw_tags = {
    Name = "${var.project}-igw"
  }

  nat_gateway_tags = {
    Name = "${var.project}-nat"
  }

  nat_eip_tags = {
    Name = "${var.project}-nat-eip"
  }

  public_route_table_tags = {
    Name = "${var.project}-public-route"
  }

  private_route_table_tags = {
    Name = "${var.project}-private-route"
  }

  tags = {
    Project = "${var.project}"
  }
}
