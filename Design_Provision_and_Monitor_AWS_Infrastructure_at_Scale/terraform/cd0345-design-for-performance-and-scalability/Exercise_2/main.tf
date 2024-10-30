provider "aws" {
  region  = var.region
  profile = "default"
}

data "archive_file" "archive" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = var.output_file_name
}

resource "aws_cloudwatch_log_group" "greet_lambda_log_group" {
  name              = "/aws/lambda/greet_lambda"
  retention_in_days = 14
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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

resource "aws_lambda_function" "greet_lambda" {
  filename      = var.output_file_name
  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.lambda_handler

  source_code_hash = data.archive_file.archive.output_base64sha256

  runtime = var.runtime

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.greet_lambda_log_group  
  ]

  environment {
    variables = {
      greeting = "Konnichiwa"
    }
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
