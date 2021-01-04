data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "ansible-pull-demo" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"

  key_name = var.key_name

  iam_instance_profile = "ansible-pull-demo-SSM_Access"

  tags = {
    Name = "ansible-pull demo"
  }

  provisioner "local-exec" {
    command = "sleep 60" # wait for instance profile to appear due to https://github.com/terraform-providers/terraform-provider-aws/issues/838
  }
  provisioner "local-exec" {
    command = "echo ${aws_iam_role.ansible-pull-demo-SSM_Access.arn}"
  }
  provisioner "local-exec" {
    command = "echo ${aws_iam_instance_profile.ansible-pull-demo-SSM_Access.arn}"
  }

  user_data = file("../user-data.sh")

}
