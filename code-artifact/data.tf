data "aws_kms_key" "kms" {
    count = var.encryption_key_alias != null ? 1 : 0
    key_id = var.encryption_key_alias
}