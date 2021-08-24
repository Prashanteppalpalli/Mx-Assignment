locals {
  vpc_id           = "vpc-3fb36158"
  subnet_id        = "subnet-e5fe84cf"
  ssh_user         = "ec2-user"
  key_name         = "devops"
  private_key_path = "C:/Users/prashant.eppalpalli/Downloads/devops.ppk"
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

######### Seed 1 Start #########

resource "aws_instance" "cassandra-cluster-seed-1" {
  ami                         = "ami-0c2b8ca1dad447f8a"
  subnet_id                   = "subnet-e5fe84cf"
  instance_type               = "t2.small"
  associate_public_ip_address = true

  vpc_security_group_ids = ["${aws_security_group.terraform-cassandra-sg.id}"]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.cassandra-cluster-seed-1.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.cassandra-cluster-seed-1.public_ip}, --private-key ${local.private_key_path} installation.yml"
  }

  provisioner "remote-exec" {
    inline = [<<-EOF
    date
    echo "waiting for Cassandra to finish installing"
    WAIT=#
    while [ ! -f /etc/cassandra/conf/cassandra.yaml ]
    do
      echo -ne "$WAIT\r"
      WAIT=$(echo $WAIT)#
        sleep 5
    done
    echo 'instance private ip - ${self.private_ip}' | sudo tee testing.txt
    sudo sed -i "s/- seeds: \"127.0.0.1\"/- seeds: \"${self.private_ip}\"/g" /etc/cassandra/conf/cassandra.yaml
    echo 'SED complete!'
    sudo reboot
    EOF
  ]

  connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.cassandra-cluster-seed-1.public_ip
    }    
  }

  tags = {
    Name =            "cassandra-cluster-seed-1"
    Description =     "Cassandra cluster deployed with terraform + ansible in AWS cloud"
  }
}

######### Seed 1 end #########

######### Seed 2 Start #########
resource "aws_instance" "cassandra-cluster-seed-2" {
  ami                         = "ami-0c2b8ca1dad447f8a"
  subnet_id                   = "subnet-e5fe84cf"
  instance_type               = "t2.small"
  associate_public_ip_address = true

  vpc_security_group_ids = ["${aws_security_group.terraform-cassandra-sg.id}"]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.cassandra-cluster-seed-2.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.cassandra-cluster-seed-2.public_ip}, --private-key ${local.private_key_path} installation.yml"
  }

  provisioner "remote-exec" {
    inline = [<<-EOF
    date
    echo "waiting for Cassandra to finish installing"
    WAIT=#
    while [ ! -f /etc/cassandra/conf/cassandra.yaml ]
    do
      echo -ne "$WAIT\r"
      WAIT=$(echo $WAIT)#
        sleep 5
    done
    echo 'instance private ip - ${self.public_ip},${aws_instance.cassandra-cluster-seed-1.public_ip}' | sudo tee testing.txt
    sudo sed -i 's/- seeds: "127.0.0.1"/- seeds: "${self.public_ip},${aws_instance.cassandra-cluster-seed-1.public_ip}"/g' /etc/cassandra/conf/cassandra.yaml
    echo 'SED complete!'
    sudo reboot
    EOF
    ]
  connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.cassandra-cluster-seed-2.public_ip
    }
  }

  tags = {
    Name =            "cassandra-cluster-seed-2"
    Description =     "Cassandra cluster deployed with terraform + ansible in AWS cloud"
  }
}

################ End Seed 2 #################

################ Start Node 1 #################
resource "aws_instance" "cassandra-cluster-node-1" {
  ami                         = "ami-0c2b8ca1dad447f8a"
  subnet_id                   = "subnet-e5fe84cf"
  instance_type               = "t2.small"
  associate_public_ip_address = true

  vpc_security_group_ids = ["${aws_security_group.terraform-cassandra-sg.id}"]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.cassandra-cluster-seed-1.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.cassandra-cluster-node-1.public_ip}, --private-key ${local.private_key_path} installation.yml"
  }

  provisioner "remote-exec" {
    inline = [<<-EOF
    date
    echo "waiting for Cassandra to finish installing"
    WAIT=#
    while [ ! -f /etc/cassandra/conf/cassandra.yaml ]
    do
      echo -ne "$WAIT\r"
      WAIT=$(echo $WAIT)#
        sleep 5
    done
    echo 'seeds - ${aws_instance.cassandra-cluster-seed-1.public_ip},${aws_instance.cassandra-cluster-seed-2.public_ip}' | sudo tee testing.txt
    sudo sed -i 's/- seeds: "127.0.0.1"/- seeds: "${aws_instance.cassandra-cluster-seed-1.public_ip},${aws_instance.cassandra-cluster-seed-2.private_ip}"/g' /etc/cassandra/conf/cassandra.yaml
    echo 'SED complete!'
    sudo reboot
    EOF
    ]
  connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.cassandra-cluster-seed-1.public_ip
    }
  } 

  tags = {
    Name =            "cassandra-cluster-node-1"
    Description =     "Cassandra cluster deployed with terraform + ansible in AWS cloud"
  }
}

############## End Node 1 ##########

resource "aws_security_group" "terraform-cassandra-sg" {
  name = "terraform-cassandra-sg"
  description = "Managed by Terraform - Allows internal connections to necessary Cassandra ports from security group"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    self = true
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["111.125.230.41/32"]
    self = true
  }

  ingress {
    from_port = 7000
    to_port = 7000
    protocol = "tcp"
    self = true
  }

  ingress {
    from_port = 7001
    to_port = 7001
    protocol = "tcp"
    self = true
  }

  ingress {
    from_port = 7199
    to_port = 7199
    protocol = "tcp"
    self = true
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    self = true
  }

  ingress {
    from_port = 9042
    to_port = 9042
    protocol = "tcp"
    self = true
  }

  ingress {
    from_port = 9160
    to_port = 9160
    protocol = "tcp"
    self = true
  }
}


output "public_dns_1" {
  value = "${aws_instance.cassandra-cluster-seed-1.public_dns}"
}

output "public_dns_2" {
  value = "${aws_instance.cassandra-cluster-seed-2.public_dns}"
}

output "public_dns_3" {
  value = "${aws_instance.cassandra-cluster-node-1.public_dns}"
}
