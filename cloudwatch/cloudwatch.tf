module "cloudwatch_metric-alarm" {
  source              = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version             = "5.3.1"
  
  alarm_name          = "cloudwatch-mt-webservers"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [var.aws_autos_policy_arn]
}

