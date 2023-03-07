#!/bin/bash

org="marafa"
repo="ansible-pull-POC"
region="us-west-2" # region for ssm parameter store can be one central location
parameter_name='/ansible-pull/git_token' # the AWS>SSM>Parameter store was previously saved as a SecureString

if grep -qiE "centos|amazon" /etc/os-release # <- it says centos OR amazon
then
    echo "INFO: $0 RPM based OS detected"
    installer=yum
    [[ $(command -v aws) ]] && yum -y update aws-cli
fi

if grep -qi ubuntu /etc/os-release # <- it says ubuntu
then
    echo "INFO: $0 APT based OS detected"
    installer="apt-get"
    apt-get update
fi

# install necessary programs
[ -f /usr/bin/unzip ] ||  ${installer} -y install unzip
[ -f /usr/bin/sudo ] ||  ${installer} -y install sudo
if ! [[ (  -f /usr/bin/aws ) || ( -f /usr/local/bin/aws ) ]]
then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
    && cd /tmp/ \
    && unzip awscliv2.zip \
    && sudo ./aws/install \
    && rm -rf aws*
fi
[ -f /usr/bin/git ] || ${installer} -y install git
[ -f /usr/bin/ansible ] || ${installer} -y install ansible
[ $? -eq 0 ] || {
    [[ $(command -v amazon-linux-extras) ]] && amazon-linux-extras install -y ansible2 || {
        # are we on the original amazon linux ami?
        yum -y install epel-release && \
        yum-config-manager --enable epel && \
        yum -y install ansible python26-boto python26-botocore
            [ $? -eq 0 ] || {
                echo "ERROR! Unknown reason!"
                exit 13
            }
        }
    }

# get the token from the parameter store
git_token=$(aws ssm get-parameters --names ${parameter_name} --with-decryption --region "${region}" --query "Parameters[].Value" --output text| sed -e 's/\[//g' -e s'/\]//g' -e 's/"//g') # jq may not be installed but sed definitely is

# download and run the local.sh script
curl -H "Authorization: token ${git_token}" \
  -H "Accept: application/vnd.github.v3.raw" \
  -L "https://api.github.com/repos/${org}/${repo}/contents/cheers.sh" | bash