#!/bin/bash

#installing Apache and Amazon EFS utlities
##### Install Ansible ######
yum update -y
curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py"
python /tmp/get-pip.py
pip install pip --upgrade
rm -fr /tmp/get-pip.py
pip install boto
pip install --upgrade ansible


cd ..
cd terraform-ansible
ansible-playbook apache-install.yml --ask-sudo-pass --extra-vars "password=$${password) efs_id=$$(efs_id)"