resource "aws_cloudwatch_metric_alarm" "pod_cpu_utilization" {
  alarm_name          = "cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric checks pod_cpu_utilization"
  alarm_actions       = [aws_sns_topic.eks_util.arn]

  dimensions = {
    "ClusterName" = aws_eks_cluster.eks_clu.name
  }
}

resource "aws_cloudwatch_metric_alarm" "pod_memory_utilization" {
  alarm_name          = "memory_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_memory_utilization"
  namespace           = "ContainerInsights"
  period              = "60"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "This metric checks pod_memory_utilization"
  alarm_actions       = [aws_sns_topic.eks_util.arn]

  dimensions = {
    "ClusterName" = aws_eks_cluster.eks_clu.name
  }
}


resource "aws_sns_topic" "eks_util" {
  name = "pod_utilization_high"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.eks_util.arn
  protocol  = "email"
  endpoint  = var.email_addresses
}


