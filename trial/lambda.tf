variable "HOSTLIST" {}
variable "EXPIRY_BUFFER" {
  default = 5
}
variable "AWS_REGION" {
  default = "us-east-1"
}

provider "aws" {
  region = "${var.AWS_REGION}"
}

resource "aws_iam_role" "SSLExpiryRole" {
  name = "SSLExpiryRole"
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


resource "aws_lambda_function" "ekspiration" {
  description = ""
  function_name = "ekspiration"
  handler = "ssl_expiry_lambda.main"
  runtime = "python3.6"
  filename = "ssl-expiry-check.zip"
  timeout = 120
  source_code_hash = "${base64sha256(file("ssl-expiry-check.zip"))}"
  role = "${aws_iam_role.SSLExpiryRole.arn}"

  environment {
    variables = {
      HOSTLIST = "${var.HOSTLIST}"
      EXPIRY_BUFFER = "${var.EXPIRY_BUFFER}"
    }
  }
}

