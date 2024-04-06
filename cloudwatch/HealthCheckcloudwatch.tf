module "cloudwatch_metric-alarm_healthcheck" {
  source              = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version             = "5.3.1"
  
  alarm_name          = "cloudwatch-mt-webservers_hc"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1

  dimensions = {
    HealthCheckId =  var.health_check_id
  }

  alarm_description   = "This metric monitors route53 health check"
  alarm_actions       = [var.sns_topic_arn]
}

