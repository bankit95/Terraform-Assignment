module "lb_sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git/?ref=master"

  name        = "sm-loadbalancer-sg"
  description = "Security group for loadbalancer with HTTP ports open publicly"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.lb_ingress
  ingress_rules       = ["http-80-tcp"]

  computed_egress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.webserver_sg.security_group_id
    }
  ]
  number_of_computed_egress_with_source_security_group_id = 1
}

module "webserver_sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git/?ref=master"

  name        = "sm-webserver-sg"
  description = "Security group for webservers with access to yum repos"
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.lb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  computed_egress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.efs1-sg.security_group_id
    },
    {
      rule                     = "all-all"
      source_security_group_id = module.efs2-sg.security_group_id
    },
    {
      rule                     = "all-all"
      source_security_group_id = module.efs3-sg.security_group_id
    }
  ]
  number_of_computed_egress_with_source_security_group_id = 3
}

module "efs1-sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git/?ref=master"

  name        = "sm-efs-mount1-sg"
  description = "Security group for efs mount target"
  vpc_id      = var.vpc_id
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.webserver_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
}

module "efs2-sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git/?ref=master"

  name        = "sm-efs-mount2-sg"
  description = "Security group for efs mount target"
  vpc_id      = var.vpc_id
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.webserver_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
}

module "efs3-sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git/?ref=master"

  name        = "sm-efs-mount3-sg"
  description = "Security group for efs mount target"
  vpc_id      = var.vpc_id
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.webserver_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
}


output "lb_sg_id" {
  value = module.lb_sg.security_group_id
}

output "webserver_sg_id" {
  value = module.webserver_sg.security_group_id
}

output "efs_mount_1-sg" {
  value = module.efs1-sg.security_group_id
}

output "efs_mount_2-sg" {
  value = module.efs2-sg.security_group_id
}

output "efs_mount_3-sg" {
  value = module.efs3-sg.security_group_id
}