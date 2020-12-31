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

  key_name  = var.key_name
  user_data = <<-EOF
  #!/bin/sh

  installer=yum

  # install dependencies
  # this is how we will retrieve the git token from parameter store
  if grep -qi centos /etc/system-release # <it says centos
  then
  	installer=yum
  	yum -y install unzip \
  	&& curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  	&& unzip awscliv2.zip \
  	&& sudo ./aws/install
  fi
  if grep -qi ubuntu /etc/system-release # <it says ubuntu
  then
  	installer=apt-get
  	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  	&& unzip awscliv2.zip \
  	&& sudo ./aws/install
  fi

  $installer -y install git
  $installer -y install ansible
  [ $? -eq 0 ] || amazon-linux-extras install ansible2

  # lets get the token from the parameter store
  region=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//')
  parameter_name='/ansible-pull/git_token' # the parameter store was saved as a SecureString
  git_token=$(aws ssm get-parameters --names $parameter_name --with-decryption --region $region --query "Parameters[].Value"| sed -e 's/\[//g' -e s'/\]//g' -e 's/"//g')

  # and finally run ansible-pull for the very first time
  [ -z $git_token ] || git_token=$git_token

   ansible-pull --directory /var/lib/ansible/local --url https://github.com/marafa/ansible-pull-demo.git --inventory /var/lib/ansible/local/hosts -l 127.0.0.1

  EOF

  tags = {
    Name = "ansible-pull demo"
  }
}

resource "aws_default_security_group" "default" {

  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
