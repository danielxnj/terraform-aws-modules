
data "aws_vpc" "default" {
  count = module.this.enabled && var.vpc_name != null ? 1 : 0
  tags = {
    Name = var.vpc_name
  }
}
