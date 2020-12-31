resource "aws_iam_role" "ansible-pull-demo-SSM_Access" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  description          = "Allows EC2 instances to call AWS services on your behalf."
  max_session_duration = "3600"
  name                 = "ansible-pull-demo-SSM_Access"
  path                 = "/"

  tags = {
    Name = "ansible-pull-demo-SSM_Access"
  }
}
