data "aws_cloudfront_cache_policy" "default_cache_behavior" {
  count = lookup(var.default_cache_behavior, "cache_policy_name", null) != null ? 1 : 0
  name  = var.default_cache_behavior.cache_policy_name
}

data "aws_cloudfront_cache_policy" "ordered_cache_behavior" {
  for_each = { for cache_behavior in var.ordered_cache_behavior : cache_behavior.target_origin_id => cache_behavior if lookup(cache_behavior, "cache_policy_name", null) != null }
  name     = each.value.cache_policy_name
}
