resource "aws_s3_bucket" "redmine" {
  bucket = "bcodmo-redmine"
  acl    = "private"

  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
}


resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.redmine.id

# This policy ensures that all objects are open for users within the whoi IP range
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "DenyAndAllowRead",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::bcodmo-redmine/*",
      "Condition": {
        "StringNotEquals": {
            "aws:sourceVpce": [
              "${aws_default_vpc.default.id}"
            ]
        },
        "NotIpAddress": {"aws:SourceIp": "${var.whoi_ip}"}
      }
    },
    {
      "Sid": "PublicReadGetObject",
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::bcodmo-redmine/*",
      "Principal": "*"
    }
  ]
}
POLICY
}

