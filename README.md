# ansible-pull-demo
demo of ansible-pull on AWS

## objectives
1. proof of concept that ansible-pull works between AWS EC2 instances and github
1. proof of concept that ansible-pull will continuously update the EC2 instance via crontab
1. proof of concept that a freshly deployed EC2 instance can be bootstrapped by ansible-pull
1. proof of concept that we can automate the EC2 ordering process and have it bootstrapped by ansible-pull

## Using
- pre-requirements: ansible and git
- modify the variable called `git_repo` in group_vars/all.yaml to point to your repo
