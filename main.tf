## create lambda package
data "archive_file" "create_lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/include"
  output_path = ".terraform/stop-start.zip"
}

resource "aws_cloudwatch_event_rule" "ec2_start" {
  count               = "${var.enabled ? 1 : 0 }"
  name                = "${var.name}-${var.envname}-wakeup"
  description         = "Capture running, stopped or terminated"
  schedule_expression = "${var.cron_start_schedule}"
}

resource "aws_cloudwatch_event_rule" "ec2_stop" {
  count               = "${var.enabled ? 1 : 0}"
  name                = "${var.name}-${var.envname}-bedtime"
  description         = "Capture running, stopped or terminated"
  schedule_expression = "${var.cron_stop_schedule}"
}

resource "aws_iam_role" "lambda" {
  count = "${var.enabled ? 1 : 0 }"
  name  = "${var.name}-${var.envname}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]

}
EOF
}

resource "aws_iam_policy" "cloudwatch_logaccess" {
  count       = "${var.enabled ? 1 : 0 }"
  name        = "${var.name}-${var.envname}-cloudwatch-logs"
  path        = "/"
  description = "cloudwatch_logs"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:Start*",
        "ec2:Stop*",
        "ec2:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attachlogaccess" {
  count      = "${var.enabled ? 1 : 0 }"
  name       = "${var.name}-${var.envname}-allow-access-to-logs"
  roles      = ["${aws_iam_role.lambda.name}"]
  policy_arn = "${aws_iam_policy.cloudwatch_logaccess.arn}"
}

resource "aws_lambda_function" "stop_start_lambda" {
  count            = "${var.enabled ? 1 : 0 }"
  filename         = ".terraform/stop-start.zip"
  source_code_hash = "${data.archive_file.create_lambda_package.output_base64sha256}"
  function_name    = "lambda-stop-start-schedule"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "start-stop.lambda_handler"
  runtime          = "python2.7"
  timeout          = "300"

  environment {
    variables = {
      region = "${var.region}"
    }
  }
}

resource "aws_cloudwatch_event_target" "ec2_start" {
  count = "${var.enabled ? 1 : 0 }"
  rule  = "${aws_cloudwatch_event_rule.ec2_start.name}"
  arn   = "${aws_lambda_function.stop_start_lambda.arn}"
}

resource "aws_cloudwatch_event_target" "ec2_stop" {
  count = "${var.enabled ? 1 : 0 }"
  rule  = "${aws_cloudwatch_event_rule.ec2_stop.name}"
  arn   = "${aws_lambda_function.stop_start_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_ec2_start" {
  count         = "${var.enabled ? 1 : 0 }"
  statement_id  = "AllowExecutionFromCloudWatchstart"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.stop_start_lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ec2_start.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_ec2_stop" {
  count         = "${var.enabled ? 1 : 0 }"
  statement_id  = "AllowExecutionFromCloudWatchstop"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.stop_start_lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ec2_stop.arn}"
}
