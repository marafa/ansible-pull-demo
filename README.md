# ansible-pull-demo
demo of ansible-pull on AWS

## objectives
- [x] proof of concept that `ansible-pull` works between AWS EC2 instances and github
- [x] proof of concept that `ansible-pull` will continuously update the EC2 instance via crontab
- [x] proof of concept that a freshly deployed EC2 instance can be bootstrapped by ansible-pull
- [ ] proof of concept that we can automate the EC2 ordering process and have it bootstrapped by ansible-pull

## Scenario 1 - already deployed EC2 instance
- pre-requirements: `ansible` and `git`
- modify group_vars/all.yaml to your liking. it includes variables like `git_repo` and `git_dir`

## Scenario 2 - freshly deployed EC2 instance
- pre-requirements from `Scenario 1` plus the `aws cli` client
- when launching an EC2 instance, copy and paste the contents of user-data.sh into `Advanced Details` "As text"ß

## Scenario 3 - private repo
- save a SecureString parameter in `AWS Systems Manager / Parameter Store`. This demo uses the name `ansible-pull/git_token`
- an IAM role attached to the EC2 instance with the `AmazonSSMManagedInstanceCore` policy

## TODO
- proof of concept that `ansible-pull` can work on a private repo
- private repo: - set up a new automation user in github and give this new user "write" access thru your organisation. see this github issue for [more info](https://github.com/jollygoodcode/jollygoodcode.github.io/issues/11)
- properly exclude AWS hostname

## Caveats
- `ansible-pull` has limitations
- playbook must be called `local.yaml`
- include is for files not proper roles, although we can shoe horn it in
- includes AWS hostname even when the host file is provided

# References
- [Using Ansible Pull In Ansible Projects](https://medium.com/splunkuserdeveloperadministrator/using-ansible-pull-in-ansible-projects-ac04466643e8)
- [ansible-pull examples](ttps://github.com/ansible/ansible-examples/blob/master/language_features/ansible_pull.yml)
- [https://github.com/jollygoodcode/jollygoodcode.github.io/issues/11](https://medium.com/planetarynetworks/ansible-pull-with-private-github-repository-d147fdf6f60b)
- [Running commands on your Linux instance at launch](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)

### References needing review
- [Running Ansible Playbooks using EC2 Systems Manager Run Command and State Manager](https://aws.amazon.com/blogs/mt/running-ansible-playbooks-using-ec2-systems-manager-run-command-and-state-manager/)
