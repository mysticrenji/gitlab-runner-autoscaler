resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096 # Create a "myKey.pem" to your computer

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
  vpc_security_group_ids      = [var.vpc_security_group_ids.id] #[aws_security_group.sg.id]
  subnet_id                   = var.subnet_id                   #aws_subnet.subnet.id
  key_name                    = aws_key_pair.kp.key_name
  iam_instance_profile        = aws_iam_instance_profile.gitlab_ec2_instance_profile.name

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

  provisioner "file" {
    source      = "/home/codespace/.ssh/mykey.pem"
    destination = "/home/ubuntu/.ssh/mykey.pem"

    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${file("/home/codespace/.ssh/mykey.pem")}"
    host     =  "${self.public_dns}"
  }
  }
}

resource "aws_launch_configuration" "asg_launch_config" {
  image_id        = var.instance_ami                # Replace with your desired AMI ID
  instance_type   = "t4g.nano"                      # Replace with your desired instance type
  security_groups = [var.vpc_security_group_ids.id] # Replace with your security group ID
  key_name        = aws_key_pair.kp.key_name        # Replace with your key pair name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "gitlab_runner_autoscaling_group" {
  name = var.asg_name
  desired_capacity     = 2
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier  = [var.subnet_id] # Replace with your subnet ID
  launch_configuration = aws_launch_configuration.asg_launch_config.id
  health_check_type    = "EC2"
}

resource "aws_iam_role" "gitlab_runner_iam_role" {
  name = "GitLabRunnerASGIAMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# resource "aws_iam_policy" "ec2_describe_policy" {
#   name        = "EC2Policy"
#   description = "EC2 role policy"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "ec2:DescribeInstances",
#           "ec2:DescribeTags"
#           # Add more actions as needed for your use case
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

resource "aws_iam_policy_attachment" "gitlab_ec2_policy_attachment" {
  name       = "EC2PolicyAttachment"
  roles      = [aws_iam_role.gitlab_runner_iam_role.name]
  policy_arn = aws_iam_policy.gitlab_runner_asg_policy.arn
}

resource "aws_iam_policy" "gitlab_runner_asg_policy" {
  name        = "GitLabRunnerASGPolicy"
  description = "Gitlab Runner EC2 ASG IAM policy"
  policy      = data.aws_iam_policy_document.policy_document.json
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    effect    = "Allow"
    resources = ["${aws_autoscaling_group.gitlab_runner_autoscaling_group.arn}"]
  }

  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "ec2:DescribeInstances"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:GetPasswordData",
      "ec2-instance-connect:SendSSHPublicKey"
    ]
    effect    = "Allow"
    resources = ["arn:aws:ec2:${var.aws_region}:${var.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/aws:autoscaling:groupName"
      values   = ["${aws_autoscaling_group.gitlab_runner_autoscaling_group.arn}"]
    }
  }
}

resource "aws_iam_instance_profile" "gitlab_ec2_instance_profile" {
  name = "GitLabRunnerEC2InstanceProfile"
  role = aws_iam_role.gitlab_runner_iam_role.name
}

