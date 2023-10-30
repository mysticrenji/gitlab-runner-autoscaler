module "network" {

  source               = "./modules/networking/"
  vpc_cidr_block       = var.vpc_cidr_block
  vpc_dns_hostnames    = var.vpc_dns_hostnames
  vpc_dns_support      = var.vpc_dns_support
  owner                = var.owner
  sg_ingress_proto     = var.sg_ingress_proto
  sg_ingress_ssh       = var.sg_ingress_ssh
  sg_egress_proto      = var.sg_egress_proto
  sg_egress_all        = var.sg_egress_all
  sg_egress_cidr_block = var.sg_egress_cidr_block
  sbn_cidr_block       = var.sbn_cidr_block
  sbn_public_ip        = var.sbn_public_ip
  aws_region           = var.aws_region
  aws_region_az        = var.aws_region_az
  rt_cidr_block        = var.rt_cidr_block

}

module "compute" {
  source                 = "./modules/compute/"
  instance_ami           = var.instance_ami
  aws_region             = var.aws_region
  aws_region_az          = var.aws_region_az
  instance_type          = var.instance_type
  root_device_size       = var.root_device_size
  root_device_type       = var.root_device_type
  owner                  = var.owner
  vpc_security_group_ids = module.network.vpc_security_group_ids
  subnet_id              = module.network.subnet_id

  depends_on = [module.network]

}