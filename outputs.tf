output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "sns_topic_arn" {
  value = aws_sns_topic.topic.arn
}