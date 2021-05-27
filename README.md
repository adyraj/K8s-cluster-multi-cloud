K8s-cluster-multi-cloud
=========

This repo contains code to to configure Kubernetes Multi-node cluster on Multi-cloud. Infrastructure for Kubernetes Master node on AWS and for Kubernetes Worker node is provisioned by Terraform and inventory for Ansible is also created dynamically which will be used by Ansible. For configuring Kubernetes Cluster Ansible playbook is executed by Terraform.

Requirements
------------

### - Install Terraform:

Install yum-config-manager to manage your repositories.
```
$ sudo yum install -y yum-utils
```
Use yum-config-manager to add the official HashiCorp Linux repository.
```
$ sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
```
Install Terraform.
```
$ sudo yum -y install terraform
```
### - Install Ansible:

For the Ansible Controller node Python 2 (version 2.7) or Python 3 (versions 3.5 and higher) should be installed.
Ansible can be installed on Red Hat 8 with pip, the Python package manager.
```
pip3 install ansible
```

### - Authenticating to AWS

AWS provider is used to interacting with many resources supported by AWS. The provider needs to be configured with proper credentials before it can be used. 
```
aws configure --profile aditya
```

### - Authenticating to Azure

Authenticate terraform to Azure by using Azure CLI. Firstly, log in to the Azure CLI using with az login command.
```
$ az login
```
Once logged in - it's possible to list the Subscriptions associated with the account via:
```
$ az account list
```
If you have more than one Subscription, you can specify the Subscription to use via the following command:
```
$ az account set --subscription="SUBSCRIPTION_ID"
```

Quick start
-----------

1. Run `terraform init`.
2. Run `terraform apply`.
3. After it's done deploying, it will output the Public IP of K8s Master node and Worker node
4. To clean up and delete all resources after you're done, run `terraform destroy`.