output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.zero_downtime_alb.dns_name
}

output "latest_task_definition_arn" {
  description = "The ARN of the latest task definition"
  value       = aws_ecs_task_definition.ecs_task.arn
}

output "container_name" {
  description = "The name of the container"
  value       = jsondecode(aws_ecs_task_definition.ecs_task.container_definitions)[0].name
}
