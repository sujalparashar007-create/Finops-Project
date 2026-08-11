output "hub_vpc_self_link" {
  value = module.hub_spoke.hub_vpc_self_link
}

output "spoke_vpc_self_links" {
  value = module.hub_spoke.spoke_vpc_self_links
}

output "ncc_hub_id" {
  value = module.hub_spoke.ncc_hub_id
}

output "firewall_rule_ids" {
  value = module.hub_spoke.firewall_rule_ids
}