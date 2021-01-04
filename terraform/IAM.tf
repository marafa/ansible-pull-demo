resource "aws_iam_role" "ansible-pull-demo-SSM_Access" {
  description          = "Allows EC2 instances to call AWS services on your behalf."
  max_session_duration = "3600"
  name                 = "ansible-pull-demo-SSM_Access"
  path                 = "/"

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

  tags = {
    Name = "ansible-pull-demo-SSM_Access"
  }
}

resource "aws_iam_instance_profile" "ansible-pull-demo-SSM_Access" {
  name = "ansible-pull-demo-SSM_Access"
  path = "/"
  role = aws_iam_role.ansible-pull-demo-SSM_Access.name
}

resource "aws_iam_role_policy_attachment" "ansible-pull-demo-SSM_Access_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ansible-pull-demo-SSM_Access.name
}
