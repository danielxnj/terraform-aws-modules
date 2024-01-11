# data "aws_caller_identity" "current" {}
data "aws_region" "default" {}

data "aws_subnet" "default" {
  count = var.subnet_name == "" ? 1 : 0
  id = var.subnet_name
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_ami" "default" {
  count       = var.ami == "" ? 1 : 0
  most_recent = "true"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_ami" "info" {
  count = var.root_volume_type != "" ? 0 : 1

  filter {
    name   = "image-id"
    values = [local.ami]
  }

  owners = [local.ami_owner]
}
