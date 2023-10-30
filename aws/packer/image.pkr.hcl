packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "gitlab-runner-ami"
  instance_type = "t4g.nano"
  region        = "eu-west-1"
  source_ami    = "ami-0d3407241b2b6ec62"
  ssh_username  = "ubuntu"
  associate_public_ip_address = true
  communicator = "ssh"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]
  provisioner "shell" {
    script = "./scripts/config-gitlab.sh"
  }
}