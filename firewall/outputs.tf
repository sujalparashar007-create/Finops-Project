output "rule_ids" {
  description = "Map of firewall rule key to firewall rule ID"
  value       = { for k, v in google_compute_firewall.rules : k => v.id }
}

output "rule_names" {
  description = "Map of firewall rule key to firewall rule name"
  value       = { for k, v in google_compute_firewall.rules : k => v.name }
}