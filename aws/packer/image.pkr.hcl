packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name                    = "gitlab-runner-ami"
  instance_type               = "t4g.micro"
  region                      = "eu-central-1"
  source_ami                  = "ami-0479653c00e0a5e59"
  ssh_username                = "ubuntu"
  associate_public_ip_address = true
  communicator                = "ssh"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]
  provisioner "shell" {
    script = "./scripts/config-gitlab.sh"
  }
}