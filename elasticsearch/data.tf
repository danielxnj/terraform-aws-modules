locals {
  is_vpc_options = length(var.vpc_options) > 0 && alltrue([for config in var.vpc_options : can(config.subnet_names)])
}

data "aws_vpc" "default" {
  count = 1
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet" "default" {
  count = local.is_vpc_options ? length(var.vpc_options.subnet_names) : 0
  vpc_id = data.aws_vpc.default[0].id 
  filter {
    name   = "tag:Name"
    values = local.is_vpc_options ? [var.vpc_options.subnet_names[count.index]] : []
  }
}