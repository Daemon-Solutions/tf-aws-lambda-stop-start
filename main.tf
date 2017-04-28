resource "aws_cloudwatch_event_rule" "ec2_start" {
  name                = "${var.name}-${var.envname}-wakeup"
  description         = "Capture running, stopped or terminated"
  schedule_expression = "${var.cron_start_schedule}"
}

resource "aws_cloudwatch_event_rule" "ec2_stop" {
  name                = "${var.name}-${var.envname}-bedtime"
  description         = "Capture running, stopped or terminated"
  schedule_expression = "${var.cron_stop_schedule}"
}

resource "aws_s3_bucket" "lambda_functions" {
  bucket = "${var.name}-${var.envname}-lambda-functions"
  acl    = "private"

  tags {
    Name = "${var.name}-${var.envname}-lambda-functions"
  }
}

resource "aws_s3_bucket_object" "start_stop" {
  depends_on = ["aws_s3_bucket.lambda_functions"]
  bucket     = "${var.name}-${var.envname}-lambda-functions"
  key        = "startstop.zip"
  source     = "${path.module}/include/startstop.zip"
}

resource "aws_iam_role" "lambda" {
  name = "${var.name}-${var.envname}-lambda-role"

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
        "ec2:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attachlogaccess" {
  name       = "${var.name}-${var.envname}-allow-access-to-logs"
  roles      = ["${aws_iam_role.lambda.name}"]
  policy_arn = "${aws_iam_policy.cloudwatch_logaccess.arn}"
}

resource "aws_lambda_function" "start_stop_lambda" {
  s3_bucket     = "${aws_s3_bucket.lambda_functions.id}"
  s3_key        = "${aws_s3_bucket_object.start_stop.id}"
  function_name = "start-stop-schedule"
  role          = "${aws_iam_role.lambda.arn}"
  handler       = "startstop.lambda_handler"
  runtime       = "python2.7"
  timeout       = "300"
}

resource "aws_cloudwatch_event_target" "ec2_start" {
  rule = "${aws_cloudwatch_event_rule.ec2_start.name}"
  arn  = "${aws_lambda_function.start_stop_lambda.arn}"
}

resource "aws_cloudwatch_event_target" "ec2_stop" {
  rule = "${aws_cloudwatch_event_rule.ec2_stop.name}"
  arn  = "${aws_lambda_function.start_stop_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_ec2_start" {
  statement_id  = "AllowExecutionFromCloudWatchstart"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.start_stop_lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ec2_start.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_ec2_stop" {
  statement_id  = "AllowExecutionFromCloudWatchstop"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.start_stop_lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ec2_stop.arn}"
}
