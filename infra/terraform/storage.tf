data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-${var.environment}-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.s3_force_destroy

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-artifacts"
    LikeC4Ref   = "vm_object_storage / backup-storage / логи и артефакты"
    Description = "S3-совместимое хранилище для бэкапов WAL, артефактов CI, архивов логов"
  })
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
