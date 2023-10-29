resource "aws_iam_role" "gitlab_runner_iam_role" {
  name = "GitLabRunnerIAMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
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
    actions   = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    effect    = "Allow"
    resources = ["${var.autoscale_grp_arn}"]
  }

  statement {
    actions   = [
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
    effect = "Allow"
    resources = ["arn:aws:ec2:${var.region}:${var.account}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/aws:autoscaling:groupName"
      values   = ["${var.autoscale_grp_arn}"]
    }
  }
}

resource "aws_iam_instance_profile" "gitlab_ec2_instance_profile" {
  name = "GitLabRunnerInstanceProfile"
  role = aws_iam_role.gitlab_runner_iam_role.name
}

