resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_notification" "eventbridge" {
  bucket      = aws_s3_bucket.bucket.id
  eventbridge = true
}

resource "aws_sns_topic" "topic" {
  name = "eventbridge-rule-example-target"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = var.email_address
}

resource "aws_iam_role" "eventbridge_role" {
  name = "eventbridge-to-sns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "events.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "sns" {
  role       = aws_iam_role.eventbridge_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_cloudwatch_event_rule" "s3_rule" {
  name = "eventbridge-rule-example"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    "detail-type" = ["Object Created"]
    detail = {
      bucket = {
        name = [var.bucket_name]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.s3_rule.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.topic.arn
  role_arn  = aws_iam_role.eventbridge_role.arn
}