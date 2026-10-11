data "aws_region" "current" {}

locals {
  name  = "${var.project}-${var.environment}"
  count = var.enabled ? 1 : 0
}

# Tópico de alertas por e-mail (a inscrição precisa ser confirmada no e-mail).
resource "aws_sns_topic" "alerts" {
  name = "${local.name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count = var.alert_email == "" ? 0 : 1

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

locals {
  # Cada alarme cobra ~US$ 0,10/mês, então só existem com enabled = true.
  alarms = var.enabled ? {
    alb_5xx = {
      namespace  = "AWS/ApplicationELB"
      metric     = "HTTPCode_Target_5XX_Count"
      stat       = "Sum"
      threshold  = 10
      dimensions = { LoadBalancer = var.alb_arn_suffix }
      desc       = "Erros 5xx no ALB"
    }
    alb_latency = {
      namespace  = "AWS/ApplicationELB"
      metric     = "TargetResponseTime"
      stat       = "Average"
      threshold  = 1
      dimensions = { LoadBalancer = var.alb_arn_suffix }
      desc       = "Latência média acima de 1s"
    }
    ecs_cpu = {
      namespace  = "AWS/ECS"
      metric     = "CPUUtilization"
      stat       = "Average"
      threshold  = 80
      dimensions = { ClusterName = var.ecs_cluster_name, ServiceName = "backend" }
      desc       = "CPU do backend acima de 80%"
    }
    ecs_memory = {
      namespace  = "AWS/ECS"
      metric     = "MemoryUtilization"
      stat       = "Average"
      threshold  = 80
      dimensions = { ClusterName = var.ecs_cluster_name, ServiceName = "backend" }
      desc       = "Memória do backend acima de 80%"
    }
    rds_cpu = {
      namespace  = "AWS/RDS"
      metric     = "CPUUtilization"
      stat       = "Average"
      threshold  = 80
      dimensions = { DBInstanceIdentifier = var.rds_instance_id }
      desc       = "CPU do RDS acima de 80%"
    }
    rds_connections = {
      namespace  = "AWS/RDS"
      metric     = "DatabaseConnections"
      stat       = "Average"
      threshold  = 60
      dimensions = { DBInstanceIdentifier = var.rds_instance_id }
      desc       = "Muitas conexões no RDS"
    }
    redis_memory = {
      namespace  = "AWS/ElastiCache"
      metric     = "DatabaseMemoryUsagePercentage"
      stat       = "Average"
      threshold  = 80
      dimensions = { ReplicationGroupId = var.redis_replication_group_id }
      desc       = "Memória do Redis acima de 80%"
    }
    redis_evictions = {
      namespace  = "AWS/ElastiCache"
      metric     = "Evictions"
      stat       = "Sum"
      threshold  = 0
      dimensions = { ReplicationGroupId = var.redis_replication_group_id }
      desc       = "Redis removendo chaves (evictions)"
    }
  } : {}
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = local.alarms

  alarm_name          = "${local.name}-${each.key}"
  alarm_description   = each.value.desc
  namespace           = each.value.namespace
  metric_name         = each.value.metric
  statistic           = each.value.stat
  dimensions          = each.value.dimensions
  period              = 300
  evaluation_periods  = 2
  threshold           = each.value.threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

# Storage livre é "menor que", por isso fica separado.
resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  count = local.count

  alarm_name          = "${local.name}-rds_free_storage"
  alarm_description   = "Menos de 2 GB livres no RDS"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  dimensions          = { DBInstanceIdentifier = var.rds_instance_id }
  period              = 300
  evaluation_periods  = 1
  threshold           = 2147483648
  comparison_operator = "LessThanThreshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_dashboard" "this" {
  count = local.count

  dashboard_name = local.name

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6
        properties = {
          title  = "ALB: requisições e 5xx"
          region = data.aws_region.current.name
          stat   = "Sum"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix],
            [".", "HTTPCode_Target_5XX_Count", ".", "."],
          ]
        }
      },
      {
        type = "metric", x = 12, y = 0, width = 12, height = 6
        properties = {
          title   = "ALB: latência (s)"
          region  = data.aws_region.current.name
          stat    = "p95"
          metrics = [["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]]
        }
      },
      {
        type = "metric", x = 0, y = 6, width = 12, height = 6
        properties = {
          title  = "ECS backend: CPU e memória (%)"
          region = data.aws_region.current.name
          stat   = "Average"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "backend"],
            [".", "MemoryUtilization", ".", ".", ".", "."],
          ]
        }
      },
      {
        type = "metric", x = 12, y = 6, width = 12, height = 6
        properties = {
          title  = "RDS: CPU e conexões"
          region = data.aws_region.current.name
          stat   = "Average"
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id],
            [".", "DatabaseConnections", ".", "."],
          ]
        }
      },
      {
        type = "metric", x = 0, y = 12, width = 12, height = 6
        properties = {
          title  = "Redis: memória (%) e evictions"
          region = data.aws_region.current.name
          stat   = "Average"
          metrics = [
            ["AWS/ElastiCache", "DatabaseMemoryUsagePercentage", "ReplicationGroupId", var.redis_replication_group_id],
            [".", "Evictions", ".", "."],
          ]
        }
      },
    ]
  })
}
