data "aws_vpc" "default" {
  count = module.this.enabled && var.vpc_name != null ? 1 : 0
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet" "default" {
  count  = module.this.enabled && var.subnet_names != null ? length(var.subnet_names) : 0
  vpc_id = var.vpc_name != null ? data.aws_vpc.default[0].id : var.vpc_id
  filter {
    name   = "tag:Name"
    values = [var.subnet_names[count.index]]
  }
}

data "aws_security_group" "default" {
  count  = module.this.enabled && var.security_group_name != null ? 1 : 0
  name   = var.security_group_name
  vpc_id = var.vpc_name != null ? data.aws_vpc.default[0].id : var.vpc_id
}

# data "aws_security_group" "selected" {
#   count  = length(var.security_group_names)
#   name   = var.security_group_names[count.index]
#   vpc_id = var.vpc_name != null ? data.aws_vpc.default[0].id : var.vpc_id
# }
