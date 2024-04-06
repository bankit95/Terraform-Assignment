variable "asg_name" {
  type        = string
  description = "Autoscaling group name"
}

variable "aws_autos_policy_arn" {
  type        = string
  description = "AWS Autoscaling Policy ARN"
}

variable "health_check_id" {
  type        = string
  description = "Route 53 health check ID"
}

variable "sns_topic_arn" {
  type        = string
  description = "arn for sns topic"
}
