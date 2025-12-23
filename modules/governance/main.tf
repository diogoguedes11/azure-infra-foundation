# Only allow location westeurope for this governance module
resource "azurerm_policy_definition" "apd_westeurope_only" {
  name         = "apd-westeurope-only"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allow only westeurope location"
  description  = "This policy allows resources to be created only in the westeurope location."

  policy_rule = <<POLICY_RULE
{
  "if": {
    "not": {
      "field": "location",
      "equals": "westeurope"
    }
  },
  "then": {
    "effect": "deny"
  }
}
POLICY_RULE
}

# Enforce use of tags on resources

resource "azurerm_policy_definition" "apd_require_tags" {
  name         = "apd-require-tags"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require tags on resources"
  description  = "This policy requires that all resources have specific tags."
  #  management_group_id (For large enterprises we should define at Mangement Group level)
  policy_rule = <<POLICY_RULE
 {
   "if": {
     "field": "tags['CostCenter']",
     "exists": "false"
   },
   "then": {
     "effect": "deny"
   }
}
POLICY_RULE
}
