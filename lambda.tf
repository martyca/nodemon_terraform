locals {
  python = {
    handler     = "lambda_function.lambda_handler"
    source_file = "${path.root}/source/python/lambda_function.py"
    runtime     = "python3.7"
  }
  node = {
    handler     = "index.handler"
    source_file = "${path.root}/source/nodejs/index.js"
    runtime     = "nodejs12.x"
  }
}

variable "lambda_name" {
  type        = string
	default     = "nodemon_lambda"
  description = "The name of the lambda."
}

resource "aws_iam_role" "role_for_lambda" {
  name = "${var.lambda_name}-role"
  assume_role_policy = <<-EOF
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

resource "aws_iam_policy" "policy_for_lambda" {
  name        = "${var.lambda_name}-policy"
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "my-attach" {
  role       = aws_iam_role.role_for_lambda.name
  policy_arn = aws_iam_policy.policy_for_lambda.arn
}

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = local.python.source_file
  output_path = "${path.root}/deploy/function.zip"
}

resource "aws_lambda_function" "lambda_function" {
  filename         = "${path.root}/deploy/function.zip"
  function_name    = var.lambda_name
  role             = aws_iam_role.role_for_lambda.arn
  handler          = local.python.handler
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256
  runtime          = local.python.runtime
}

output "lambda_ARN" {
  value       = aws_lambda_function.lambda_function.arn
  description = "The ARN of the deployed lambda."
}
output "lambda_name" {
  value       = aws_lambda_function.lambda_function.function_name
  description = "The name of the deployed lambda."
}
