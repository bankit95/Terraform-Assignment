module "asg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-autoscaling.git/?ref=master"


  name            = "sm-test-asg"
  image_id        = var.ami_id
  instance_type   = var.instance_type
  security_groups = [var.web_sg_id]
  user_data       = templatefile("${path.module}/userdataAnsible.sh", { efs_id = var.efs_id, password = var.password })

  block_device_mappings = [
    {
      # Root volume
      device_name = "/test/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 70
        volume_type           = "gp2"
      }
    }, {
      device_name = "/var/log2"
      no_device   = 1
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 50
        volume_type           = "gp2"
      }
    }
  ]

  vpc_zone_identifier       = var.subnet_webservers
  health_check_type         = "ELB"
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_grace_period = 60
  target_group_arns         = module.alb.target_groups.arn
  enabled_metrics           = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]

  tags  = {
    Server      = "WebServer"
    Environment = "test"
  }
}

output "asg_name" {
  value = module.asg.autoscaling_group_name
}