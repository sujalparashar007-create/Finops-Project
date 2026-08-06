output "org_policy_id" {
  description = "Full resource ID of the org-level firewall policy"
  value       = module.org_policy.policy_id
}

output "folder_policy_id" {
  description = "Full resource ID of the folder-level firewall policy"
  value       = module.folder_policy.policy_id
}
