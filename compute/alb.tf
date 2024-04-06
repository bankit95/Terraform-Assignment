module "alb" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git/?ref=master"

  name = "sm-test-lb"

  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  subnets         = var.subnet_loadbalancer
  security_groups = [var.lb_sg_id]

  target_groups = {
    ex-sm-tgs = {
      name_prefix      = "sm-tg"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 60
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 6
        timeout             = 50
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  }
  

   listeners = {
     ex-https = {
        port            = 443
        protocol        = "HTTPS"
        certificate_arn = var.certificate_arn

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  tags = {
    Name        = "sm-load-balancer"
    Environment = "test"
  }
}

output "alb_dns" {
  value = module.alb.dns_name
}