data "aws_cloudfront_cache_policy" "default_cache_behavior" {
  count = lookup(var.default_cache_behavior, "cache_policy_name", null) != null ? 1 : 0
  name  = var.default_cache_behavior.cache_policy_name
}

data "aws_cloudfront_cache_policy" "ordered_cache_behavior" {
  for_each = toset([for cb in var.ordered_cache_behavior : cb.cache_policy_name if cb.cache_policy_name != null])
  name     = each.value
}
