data "aws_kms_key" "kms" {
    count = var.repository_kms_key_alias != null ? 1 : 0
    key_id = var.repository_kms_key_alias
}