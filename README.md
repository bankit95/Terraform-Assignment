# Terraform assessment

This repository holds the code for the 'Terraform assessment' project,
The terraform project deploys a web application and creates following resources -
- Load balancer with an autoscaling group
- Elasctic file system
- VPC along with private and public subnets


## Requirements
Name | Version
---------|-------
Terraform | v1.7 or above
AWS Provider	| v5.4 or above

## Design requirments
The Assignment:
Using Terraform latest version, build a module meant to deploy a web application that 
supports the following design:
1. It must include a VPC which enables future growth / scale.
2. It must include both a public and private subnet – where the private subnet is used 
for compute and the public is used for the load balancers.
3. Assuming that the end-users only contact the load balancers, and the underlying 
instance are accessed for management purposes, design a security group scheme 
which supports the minimal set of ports required for communication.
4. The AWS generated load balancer hostname with be used for request to the public 
facing web application.
5. An autoscaling group should be created which utilizes the latest AWS AMI
6. The instance in the ASG Must contain both a root volume to store the application / 
services and must contain a secondary volume meant to store any log data bound 
from / var/log.
7. Must include a web server of your choice.
8. Configure web application using Ansible, all requirements in this task of configuring 
the operating system should be defined in the launch configuration and/or the user 
data script.
9. Create self-signed certificate for test.example.com and used this hostname with Load 
balancer, this dns should be resolve internally within VPC network with route 53 
private hosted zone.
Your completed module should include a README which explains the module inputs 
and any important design decisions you made which may assist in evaluation.
Your module should not be tightly coupled to your AWS account – it should be 
designed to that it can be deployed to any arbitrary AWS account.
ASSIGNMENT
Additional Areas to Focus On (Extra Credit):
1. You must ensure that all data is encrypted at rest.
2. Ideally, you should design these web servers so they can be managed without logging 
in with the root key.
3. We should have CloudWatch alarm mechanism that indicates when the application is 
experiencing any issues.
4. Configure the autoscaling group to automatically add and remove nodes based on 
load



## How to use this code

Follow the below instructiosn to deploy infrastructure using this code:

- Clone the code using following:
 `git clone https://github.com/bankit95/Terraform-Assignment.git`
- Make sure you have installed AWS CLI on your PC. If not, download from the following link:
    https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html
- Configure AWS credentials by opening cmd and running following command:
 `aws configure`
 - Code uses AWS cred file so make sure you have AWS cred file stored in following windows path:
  `%USERPROFILE%\.aws\credentials`
  - Open CMD, go to the path where the main.tf file is stored and run following command to initialise and download Terraform module and plugins
   `terraform init`
   - Run following commands to see the deployment plan and to deploy infrastructure respectively
    `terraform plan` (Verify the plan)
    `terraform apply` (Enter yes when asked whether to deploy or not)
 
 
 # duplication 
 userdata.sh has been created in addition to  userdataAnsible.sh doing same work directly instead of using ansible.



## Changelog
Version | Comment
---------|-------
1.0 | Initial commit