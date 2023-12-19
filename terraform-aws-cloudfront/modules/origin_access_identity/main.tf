
resource "aws_cloudfront_origin_access_identity" "this" {
  count   = var.comment != null ? 1 : 0
  comment = var.comment

  lifecycle {
    create_before_destroy = true
  }
}
