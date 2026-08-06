output "function_name" {
  description = "Cloud Function name"
  value       = module.finops_function.function_name
}

output "function_uri" {
  description = "Cloud Function trigger URI"
  value       = module.finops_function.function_uri
}

output "bucket_name" {
  description = "GCS bucket storing function source code"
  value       = module.finops_function.bucket_name
}
