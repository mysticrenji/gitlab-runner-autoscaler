# create-vpc.tf
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_dns_hostnames
  enable_dns_support   = var.vpc_dns_support
 
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-vpc"
  }
}

# create-sg.tf
 
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
 
resource "aws_security_group" "sg" {
  name        = "${var.owner}-sg"
  description = "Allow inbound traffic via SSH"
  vpc_id      = aws_vpc.vpc.id
 
  ingress = [{
    description      = "My public IP"
    protocol         = var.sg_ingress_proto
    from_port        = var.sg_ingress_ssh
    to_port          = var.sg_ingress_ssh
    cidr_blocks      = ["${chomp(data.http.myip.body)}/32"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
 
  }]
 
  egress = [{
    description      = "All traffic"
    protocol         = var.sg_egress_proto
    from_port        = var.sg_egress_all
    to_port          = var.sg_egress_all
    cidr_blocks      = [var.sg_egress_cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
 
  }]
 
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-sg"
  }
}

#create-sbn.tf
 
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.sbn_cidr_block
  map_public_ip_on_launch = var.sbn_public_ip
  availability_zone       = "${var.aws_region}${var.aws_region_az}"
 
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-subnet"
  }
}

# create-igw.tf
 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
 
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-igw"
  }
}

#create-rt.tf
 
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
 
  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }
 
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-rt"
  }
 
}

resource "aws_route_table_association" "rt_sbn_asso" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}