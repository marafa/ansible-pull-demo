# ansible-pull-demo
demo of ansible-pull on AWS

## objectives
1. proof of concept that ansible-pull works between AWS EC2 instances and github
1. proof of concept that ansible-pull will continuously update the EC2 instance via crontab
1. proof of concept that a freshly deployed EC2 instance can be bootstrapped by ansible-pull
1. proof of concept that we can automate the EC2 ordering process and have it bootstrapped by ansible-pull

## Using
- pre-requirements: ansible and git
- modify group_vars/all.yaml to point to your liking. it includes variables like `git_repo` and `git_dir` 
- set up a new automation user in github and give this new user "write" access thru. see this github issue for [more info](https://github.com/jollygoodcode/jollygoodcode.github.io/issues/11)
