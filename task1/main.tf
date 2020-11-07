provider "aws" {
  profile = "default"
  version = "3.0"
  region  = "us-east-1"
}

# Create the Security Group
resource "aws_security_group" "Nginx" {
  name         = "NginxSG"
  description  = "NginxSG"
  
  # allow ingress of port 22
  ingress {
    cidr_blocks = ["0.0.0.0/0"]  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 

  ingress {
    cidr_blocks = ["0.0.0.0/0"]  
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  } 

  
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
   Name = "Web Security Group"
   Description = "My VPC Security Group"
  }
} # end resource

resource "aws_instance" "first_node" {
  ami                    = "ami-0947d2ba12ee1ff75"
  instance_type          = "t2.micro"
  key_name               = "Nginx_key"
  vpc_security_group_ids = [aws_security_group.Nginx.id]
  user_data              = file("favour.sh")
  tags = {
    Name        = "Nginx"
    Provisioner = "Terraform"
    Test        = "yes_no"
  }
}

resource "tls_private_key" "sshkeygen_execution" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "keyLocal" {
  content         = tls_private_key.sshkeygen_execution.private_key_pem
  filename        = "Nginx_key.pem"
  file_permission = 0400
}

resource "aws_key_pair" "Nginx_key_pair" {
  depends_on = [tls_private_key.sshkeygen_execution]
  key_name   = "Nginx_key"
  public_key = tls_private_key.sshkeygen_execution.public_key_openssh
}

resource "null_resource" "firstnode-provisioner" {

    triggers = {
    public_ip = aws_instance.first_node.public_ip
  }
    connection {
    user          = "ec2-user"
    #host          = self.public_ip
    host          = aws_instance.first_node.public_ip
    private_key   = tls_private_key.sshkeygen_execution.private_key_pem

  }

  # Copy the  file to instance
  provisioner "file" {
    source      = "./index.html"
    destination = "/home/ec2-user/index.html"
  }

   provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html"
    ]
  }
}