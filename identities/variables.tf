# ==============================================================================
# MODULE: identities — variables
# ==============================================================================

variable "service_accounts" {
  description = "Flat map of Service Accounts to create: key = account_id, value = its config."
  type = map(object({
    project_id   = string
    display_name = string
    roles        = list(string) # roles granted to this SA, in its own project
  }))
}
