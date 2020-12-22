resource "aws_flow_log" "webserver" {
  iam_role_arn    = aws_iam_role.webserver.arn
  log_destination = aws_cloudwatch_log_group.webserver.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.default.id
}

resource "aws_cloudwatch_log_group" "webserver" {
  name = "webserver"
}

resource "aws_iam_role" "webserver" {
  name = "webserver"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "webserver" {
  name = "webserver"
  role = aws_iam_role.webserver.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}