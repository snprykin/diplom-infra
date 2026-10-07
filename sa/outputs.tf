output "sa_id" {
  value       = yandex_iam_service_account.diplom-sa.id
  description = "Service account ID"
}

output "sa_key_id" {
  value       = yandex_iam_service_account_static_access_key.sa-key.access_key
  description = "Static access key ID for S3"
  sensitive   = true
}

output "sa_secret" {
  value       = yandex_iam_service_account_static_access_key.sa-key.secret_key
  description = "Static secret key for S3"
  sensitive   = true
}

output "bucket_name" {
  value       = yandex_storage_bucket.tfstate.bucket
  description = "Terraform state bucket name"
}
