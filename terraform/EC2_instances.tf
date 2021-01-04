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

  user_data = <<-EOF
  #!/bin/sh

installer=yum # default installer
parameter_name='/ansible-pull/git_token' # the parameter store was saved as a SecureString
org="marafa-sugarcrm"

# install dependencies
# this is how we will retrieve the git token from parameter store
if grep -qi centos /etc/system-release # <- it says centos
then
	installer=yum
	yum -y install unzip
fi
if grep -qi ubuntu /etc/system-release # <- it says ubuntu
then
	installer=apt-get
fi
if grep -qi amazon /etc/system-release # <- it says centos
then
	installer=yum
	yum -y install unzip
fi

# install necessary programs
[ -f /usr/local/bin/aws ] || {
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
&& unzip awscliv2.zip \
&& sudo ./aws/install
}
$installer -y install git
$installer -y install ansible
[ $? -eq 0 ] || amazon-linux-extras install ansible2

# lets get the token from the parameter store
region=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//')
git_token=$(aws ssm get-parameters --names $parameter_name --with-decryption --region $region --query "Parameters[].Value" --output text| sed -e 's/\[//g' -e s'/\]//g' -e 's/"//g')
echo git_token= $git_token

# and finally run ansible-pull for the very first time
if ! [ -z $git_token ]
then
    git_cmd=$git_token:x-oauth-basic@github.com
else
    git_cmd=github.com
fi

# lets pull everything together:
# NOTE: the directory should be the same as in the crontab

ansible-pull --directory /var/lib/ansible/local --url https://$git_cmd/$org/ansible-pull-POC.git --inventory /var/lib/ansible/local/hosts --limit 127.0.0.1

EOF

}
