resource "aws_sns_topic" "alarms" {
  name = "${var.app_name}-${var.environment}-alarms"
  tags = { environment = var.environment }
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  for_each = toset(var.service_names)

  alarm_name          = "${var.app_name}-${var.environment}-${each.key}-cpu-high"
  alarm_description   = "CPU de ${each.key} superó ${var.cpu_threshold}% — Escalar servicio o revisar memory leak en /ecs/${var.app_name}-${var.environment}/${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = each.key
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = { environment = var.environment, service = each.key }
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  for_each = toset(var.service_names)

  alarm_name          = "${var.app_name}-${var.environment}-${each.key}-memory-high"
  alarm_description   = "Memoria de ${each.key} superó ${var.memory_threshold}% — Aumentar memory limit en task definition o revisar leaks"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.memory_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = each.key
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = { environment = var.environment, service = each.key }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.app_name}-${var.environment}-alb-5xx-errors"
  alarm_description   = "Errores 5XX en ALB superaron ${var.error_5xx_threshold} — Revisar logs de ui y admin en CloudWatch Logs"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.error_5xx_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = { environment = var.environment }
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts_ui" {
  alarm_name          = "${var.app_name}-${var.environment}-ui-unhealthy-hosts"
  alarm_description   = "UI tiene hosts caídos — Revisar ECS task status y health checks"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.unhealthy_hosts_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.ui_tg_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = { environment = var.environment }
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts_admin" {
  alarm_name          = "${var.app_name}-${var.environment}-admin-unhealthy-hosts"
  alarm_description   = "Admin tiene hosts caídos — Revisar ECS task status, DB connection y variables de entorno"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.unhealthy_hosts_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.admin_tg_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = { environment = var.environment }
}

resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  alarm_name          = "${var.app_name}-${var.environment}-alb-latency"
  alarm_description   = "Latencia del ALB superó ${var.response_time_threshold}s — Revisar DB, dependencias internas y scaling"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = var.response_time_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = { environment = var.environment }
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.app_name}-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "text"; x = 0; y = 0; width = 24; height = 1
        properties = { markdown = "## ${var.app_name} — ${var.environment} | CPU · Memoria · Errores · Latencia · Disponibilidad" }
      },

      {
        type = "metric"; x = 0; y = 1; width = 12; height = 6
        properties = {
          title  = "CPU Utilization — todos los servicios"
          region = var.aws_region; period = 300; stat = "Average"; view = "timeSeries"
          metrics = [
            for s in var.service_names :
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.cluster_name, "ServiceName", s, { label = s }]
          ]
          annotations = { horizontal = [{ value = var.cpu_threshold, label = "Límite", color = "#ff6961" }] }
        }
      },

      {
        type = "metric"; x = 12; y = 1; width = 12; height = 6
        properties = {
          title  = "Memory Utilization — todos los servicios"
          region = var.aws_region; period = 300; stat = "Average"; view = "timeSeries"
          metrics = [
            for s in var.service_names :
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.cluster_name, "ServiceName", s, { label = s }]
          ]
          annotations = { horizontal = [{ value = var.memory_threshold, label = "Límite", color = "#ff6961" }] }
        }
      },

      {
        type = "metric"; x = 0; y = 7; width = 8; height = 6
        properties = {
          title  = "ALB — Request Count"
          region = var.aws_region; period = 300; stat = "Sum"; view = "timeSeries"
          metrics = [["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]]
        }
      },

      {
        type = "metric"; x = 8; y = 7; width = 8; height = 6
        properties = {
          title  = "ALB — Errores 5XX"
          region = var.aws_region; period = 300; stat = "Sum"; view = "timeSeries"
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, { label = "Target 5XX" }],
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count",    "LoadBalancer", var.alb_arn_suffix, { label = "ELB 5XX" }]
          ]
          annotations = { horizontal = [{ value = var.error_5xx_threshold, label = "Límite", color = "#ff6961" }] }
        }
      },

      {
        type = "metric"; x = 16; y = 7; width = 8; height = 6
        properties = {
          title  = "ALB — Latencia promedio"
          region = var.aws_region; period = 300; stat = "Average"; view = "timeSeries"
          metrics = [["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]]
          annotations = { horizontal = [{ value = var.response_time_threshold, label = "Límite", color = "#ff6961" }] }
        }
      },

      {
        type = "metric"; x = 0; y = 13; width = 12; height = 6
        properties = {
          title  = "ALB — Hosts Saludables"
          region = var.aws_region; period = 60; stat = "Average"; view = "timeSeries"
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount",   "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.ui_tg_arn_suffix,    { color = "#2ca02c", label = "UI Healthy" }],
            ["AWS/ApplicationELB", "UnHealthyHostCount", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.ui_tg_arn_suffix,    { color = "#d62728", label = "UI Unhealthy" }],
            ["AWS/ApplicationELB", "HealthyHostCount",   "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.admin_tg_arn_suffix, { color = "#1f77b4", label = "Admin Healthy" }],
            ["AWS/ApplicationELB", "UnHealthyHostCount", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.admin_tg_arn_suffix, { color = "#ff7f0e", label = "Admin Unhealthy" }]
          ]
        }
      },

      {
        type = "alarm"; x = 12; y = 13; width = 12; height = 6
        properties = {
          title = "Estado de Alarmas"
          alarms = concat(
            [for s in var.service_names : aws_cloudwatch_metric_alarm.cpu_high[s].arn],
            [for s in var.service_names : aws_cloudwatch_metric_alarm.memory_high[s].arn],
            [
              aws_cloudwatch_metric_alarm.alb_5xx.arn,
              aws_cloudwatch_metric_alarm.unhealthy_hosts_ui.arn,
              aws_cloudwatch_metric_alarm.unhealthy_hosts_admin.arn,
              aws_cloudwatch_metric_alarm.alb_response_time.arn,
            ]
          )
        }
      }
    ]
  })
}

resource "aws_lambda_function" "alarm_notifier" {
  filename         = "${path.module}/lambda_notifier.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_notifier.zip")
  function_name    = "${var.app_name}-${var.environment}-alarm-notifier"
  role             = var.lambda_role_arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"

  environment {
    variables = {
      WEBHOOK_URL = var.webhook_url
    }
  }

  tags = { environment = var.environment }
}

resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alarm_notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarms.arn
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.alarm_notifier.arn
}