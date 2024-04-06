terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.4"
    }
  }
}

provider "aws" {
  alias                   = "awsp1"
  region                  = var.aws_region
  shared_credentials_files = [var.aws_cred_file_path]
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "privatekey" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "certificatebody" {
  private_key_pem = tls_private_key.privatekey.private_key_pem

  subject {
    common_name  =  "test.example.com"
    organization = "sm terraform assignment"
  }
  dns_names = ["test.example.com"]

  validity_period_hours = 1000

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "tlscert" {
  private_key      = tls_private_key.privatekey.private_key_pem
  certificate_body = tls_self_signed_cert.certificatebody.cert_pem
}


module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git/?ref=master"

  name = "sm-vpc"
  cidr = "10.0.0.0/16"

  azs                   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnet_suffix = "-private"
  private_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_suffix  = "-public"
  public_subnets        = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  enable_vpn_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "SM-VPC"
    Environment = "test"
    Description = "VPC for SM applications"
  }

}

module "security_groups" {
  source     = "./security_groups"
  vpc_id     = module.vpc.vpc_id
  lb_ingress = var.lb_ingress
}

module "efs" {
  source = "./storage"

  subnet1_id = module.vpc.private_subnets[0]
  subnet2_id = module.vpc.private_subnets[1]
  subnet3_id = module.vpc.private_subnets[2]
  efs-mt1-sg = module.security_groups.efs_mount_1-sg
  efs-mt2-sg = module.security_groups.efs_mount_2-sg
  efs-mt3-sg = module.security_groups.efs_mount_3-sg
}

module "compute" {
  source              = "./compute"
  ami_id              = data.aws_ami.amazon-linux-2.id
  instance_type       = var.instance_type
  web_sg_id           = module.security_groups.webserver_sg_id
  subnet_webservers   = module.vpc.private_subnets
  vpc_id              = module.vpc.vpc_id
  subnet_loadbalancer = module.vpc.public_subnets
  lb_sg_id            = module.security_groups.lb_sg_id
  efs_id              = module.efs.efs_id
  password            = var.password
  certificate_arn     = aws_acm_certificate.tlscert.arn
}


resource "aws_autoscaling_policy" "aws_autoscaling_policy1" {
  name                   = "aws_autoscaling_monitor"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = module.compute.asg_name
}

resource "aws_route53_zone" "private53_zone" {
  name = "example.com"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_record" "dns_routing" {
  zone_id = aws_route53_zone.private53_zone.zone_id
  name    = module.compute.alb_dns
  type    = "CNAME"
  ttl     = 5
  set_identifier = "test"
  records        = ["test.example.com"]
}


resource "aws_route53_health_check" "wwebservice_healthcheck" {
  fqdn              = module.compute.alb_dns
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "tf-health-check"
  }
}

resource "aws_sns_topic" "topic" {
  name     = "Webservice-healthcheck"
  provider = aws.awsp1
}

module "cloudwatch" {
  source                  = "./cloudwatch"
  asg_name                = module.compute.asg_name
  aws_autos_policy_arn    = aws_autoscaling_policy.aws_autoscaling_policy1.arn
  health_check_id         = aws_route53_health_check.wwebservice_healthcheck.id
  sns_topic_arn           = aws_sns_topic.topic.arn
}



## Outputs

output "load_balancer_dns" {
  value = module.compute.alb_dns
}

output "efs_id" {
  value = module.efs.efs_id
}