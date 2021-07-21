
provider "aws" {
    profile="default"
    region="ap-south-1"
}


# Step_1 : Create a key pair

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "keypair_for_terraform_task-2"
  public_key = tls_private_key.this.public_key_openssh
}


# step_2 : Create a Security Group


resource "aws_security_group" "sg_for_terraform_task-2" {
  name = "sg_for_terraform_task-2"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "sg_for_terraform_task-2"
  }
}


# step_3 : Launch an ec2 instance


resource "aws_instance" "task2" {
    ami = "ami-00bf4ae5a7909786c"
    key_name = "keypair_for_terraform_task-2" 
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.sg_for_terraform_task-2.id]


    tags = {
        Name = "instance_for _terraform_task-2"
          }
}


# step_4 : Create an ebs volume


resource "aws_ebs_volume" "volume" {
    availability_zone = aws_instance.task2.availability_zone
    size = 10
    tags = {
        Name = "ebs_for_terraform_task-2"
         }
}


# step_5 : Attaching volume to instance


resource "aws_volume_attachment" "ebs_att_task-2" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.volume.id
  instance_id = aws_instance.task2.id
}




