output "cloudwatch_event_rule_start_arn" {
  value = "${aws_cloudwatch_event_rule.ec2_start.arn}"
}

output "cloudwatch_event_rule_stop_arn" {
  value = "${aws_cloudwatch_event_rule.ec2_stop.arn}"
}
