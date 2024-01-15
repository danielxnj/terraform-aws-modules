data "aws_vpc" "default" {
  count = 1
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet" "default" {
  count = lookup(var.vpc_options, "subnet_names", null) != null ? length(var.vpc_options.subnet_names) : 0
  vpc_id = data.aws_vpc.default[0].id 
  filter {
    name   = "tag:Name"
    values =  [var.vpc_options.subnet_names[count.index]]
  }
}

data "aws_kms_key" "kms" {
    count = lookup(var.encrypt_at_rest, "kms_key_alias", null) != null ? 1 : 0
    key_id = lookup(var.encrypt_at_rest, "kms_key_alias", null)
}
