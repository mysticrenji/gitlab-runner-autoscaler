resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096    # Create a "myKey.pem" to your computer

  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > /home/codespace/.ssh/mykey.pem"
  }
}

resource "aws_key_pair" "kp" { # Create a "myKey" to AWS
  key_name   = "myKey"
  public_key = tls_private_key.pk.public_key_openssh
}



# create-instance.tf
 
resource "aws_instance" "instance" {
  ami                         = var.instance_ami
  availability_zone           = "${var.aws_region}${var.aws_region_az}"
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.vpc_security_group_ids.id]#[aws_security_group.sg.id]
  subnet_id                   = var.subnet_id #aws_subnet.subnet.id
  key_name                    = aws_key_pair.kp.key_name
 
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = var.root_device_size
    volume_type           = var.root_device_type
  }
 
  tags = {
    "Owner"               = var.owner
    "Name"                = "${var.owner}-instance"
    "KeepInstanceRunning" = "false"
  }
}

resource "aws_launch_configuration" "asg_launch_config" {
  name               = "GitLabASG"
  image_id           = "your_ami_id"         # Replace with your desired AMI ID
  instance_type      = "t4g.nano"            # Replace with your desired instance type
  security_groups    = [var.vpc_security_group_ids.id]  # Replace with your security group ID
  key_name           = aws_key_pair.kp.key_name       # Replace with your key pair name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "gitlab_runner_autoscaling_group" {
  desired_capacity     = 2
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier  = [var.subnet_id]     # Replace with your subnet ID
  launch_configuration = aws_launch_configuration.asg_launch_config.id
  health_check_type    = "EC2"
}