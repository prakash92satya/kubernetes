provider "aws" {
  region     = "us-east-1"
  access_key = "XXXXXXXXXXXXXXXXXXXXXX"
  secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}

resource "aws_instance" "ec2_instance" {
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.demosg.id]
  key_name               = "satya_terraform"
  tags = {
    Name = "Terraform-1"
  }
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  provisioner "file" {
    source      = "install_docker.sh"
    destination = "/home/ubuntu/install_docker.sh"
  }
  provisioner "file" {
    source      = "minikube.sh"
    destination = "/home/ubuntu/minikube.sh"
  }

  provisioner "local-exec" {
    command = "echo done"
  }
  provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
      "mkdir scripts",
      "mv * scripts",
      "sudo chmod +x scripts/install_docker.sh",
      "sudo chmod +x scripts/minikube.sh"
    ]
  }
  # "./scripts/minikube.sh"

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("id_ed25519")
    timeout     = "1m"
  }
}

resource "aws_security_group" "demosg" {
  description = "Allow HTTP and SSH traffic via Terraform"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "satya_terraform"
  public_key = "ssh-ed25519 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXCHtoyJIrPwlC+YSl "
}

output "ec2instance" {
  value = aws_instance.ec2_instance.public_ip
}

output "ec2instance_id" {
  value = aws_instance.ec2_instance.id
}