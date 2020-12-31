#!/bin/sh

installer=yum

# install dependencies
# this is how we will retrieve the git token from parameter store
if grep -qi centos /etc/system-release # <- it says centos
then
	installer=yum
	yum -y install unzip \
	&& curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
	&& unzip awscliv2.zip \
	&& sudo ./aws/install
fi
if grep -qi ubuntu /etc/system-release # <- it says ubuntu
then
	installer=apt-get
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
	&& unzip awscliv2.zip \
	&& sudo ./aws/install
fi
if grep -qi amazon /etc/system-release # <- it says centos
then
	installer=yum
	yum -y install unzip \
	&& curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
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
echo git_token= $git_token

# and finally run ansible-pull for the very first time
[ -z $git_token ] || git_token=$git_token

ansible-pull --directory /var/lib/ansible/local --url https://github.com/marafa/ansible-pull-demo.git --inventory /var/lib/ansible/local/hosts -l 127.0.0.1
