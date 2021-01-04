#!/bin/sh

installer=yum # default installer
parameter_name='/ansible-pull/git_token' # the parameter store was saved as a SecureString
org="marafa"
directory=/var/lib/ansible/local

# install dependencies
# this is how we will retrieve the git token from parameter store
if grep -qi centos /etc/system-release # <- it says centos
then
	installer=yum
        [ -f /usr/bin/zip ] ||  yum -y install unzip
fi
if grep -qi ubuntu /etc/system-release # <- it says ubuntu
then
	installer=apt-get
fi
if grep -qi amazon /etc/system-release # <- it says centos
then
	installer=yum
        [ -f /usr/bin/zip ] ||  yum -y install unzip
fi

# install necessary programs
[ -f /usr/local/bin/aws ] || {
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
&& unzip awscliv2.zip \
&& sudo ./aws/install
}
[ -f /usr/bin/git ] || $installer -y install git
[ -f /usr/bin/ansible ] || $installer -y install ansible
[ $? -eq 0 ] || amazon-linux-extras install ansible2

# lets get the token from the parameter store
region=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//')
git_token=$(aws ssm get-parameters --names $parameter_name --with-decryption --region $region --query "Parameters[].Value" --output text| sed -e 's/\[//g' -e s'/\]//g' -e 's/"//g')

# and finally run ansible-pull for the very first time
if ! [ -z $git_token ]
then
    git_cmd=$git_token:x-oauth-basic@github.com
else
    git_cmd=github.com
fi

# lets pull everything together:
# NOTE: the directory should be the same as in the crontab

ansible-pull --directory $directory --url https://$git_cmd/$org/ansible-pull-POC.git --inventory $directory/hosts --limit 127.0.0.1
