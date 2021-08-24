# Agenda
This terraform + ansible combination scripts will deploy cassandra 3 node cluster in AWS cloud.

# Infrastructure Code
This repo contains common infrastructure code and configuration. You will need to download and install terraform + ansibble on your system.
 * Ansible tasks
 * Terraform setup

# Prerequisites and Required Tools

- AWS account and credentials (ACCESS_KEY and SECRET_KEY)
- Terraform installation on local machine
- Ansibe installation on local machine
- local values as mentioned in main.tf file.

            locals {
              vpc_id           = "vpc-3fb36158"
              subnet_id        = "subnet-e5fe84cf"
              ssh_user         = "ec2-user"
              key_name         = "devops"
              private_key_path = "C:/Users/{user}/Downloads/devops.ppk"
            } 


# Steps to run this scripts on AWS cloud.

- Set / export ACCESS_KEY and SECRET_KEY on your terminal (CMD / gitbash)
- **terraform init** >> Terraform initialization Step to fetch required providers and dependencies

- **terraform plan** >> Plan your resoures

- **terraform apply** >> Apply your resources


# Ansible Invocation is happening in main.tf for all three servers.

    provisioner "local-exec" {
        command = "ansible-playbook  -i ${aws_instance.cassandra-cluster-seed-1.public_ip}, --private-key ${local.private_key_path} installation.yml"
      }
