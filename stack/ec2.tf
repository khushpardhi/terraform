module "ec2" {
  source = "../modules/ec2/"
  instance_type = "t2.micro" 
  ec2_sg_id = module.vpc.security_group_id 
  ec2_subnet_id = module.vpc.subnet_id  
}
module "ec2" {
  source = "../modules/ec2/"
  instance_type = "t2.micro" 
  ec2_sg_id = module.vpc.security_group_id 
  ec2_subnet_id = module.vpc.subnet_id  
}
