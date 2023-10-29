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
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami = "ami-0571c1aedb4b8c5fc"
  ssh_username = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    script = "./scripts/config-gitlab.sh"
  }
}