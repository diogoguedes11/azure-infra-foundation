output "dcr_id_output" {
  value       = azurerm_monitor_data_collection_rule.linux_dcr.id
  description = "O ID da Data Collection Rule para ser usado noutros módulos"
}

output "law_id_output" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "O ID do Log Analytics Workspace"
}
