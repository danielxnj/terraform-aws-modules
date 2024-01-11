
# data "aws_lb" "default" {
#   count = var.create ? 1 : 0
#   name  = var.lb_name
# }

# data "aws_lb" "listener_rule" {
#   count = var.create && var.create_aws_lb_listener == false ? 1 : 0
#   name  = var.listener_rule_lb_name
# }

# data "aws_lb_listener" "listener_rule" {
#   for_each          = var.create && var.create_aws_lb_listener == false ? var.listener_rules : {}
#   load_balancer_arn = data.aws_lb.listener_rule[0].arn
#   port              = each.value.port
# }

data "aws_vpc" "default" {
  count = var.vpc_name != null ? 1 : 0
  tags = {
    Name = var.vpc_name
  }
}