locals {
  is_valid_network_config = length(var.vpc_options) > 0 && alltrue([for config in var.vpc_options : can(config.subnet_names)])
}

data "aws_subnet" "default" {
  count = local.is_valid_network_config ? length(var.vpc_options[0].subnet_names) : 0
  vpc_id = var.vpc_name != null ? data.aws_vpc.default[0].id : var.vpc_id
  filter {
    name   = "tag:Name"
    values = local.is_valid_network_config ? [var.vpc_options[0].subnet_names[count.index]] : []
  }
}