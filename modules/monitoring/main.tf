
# log analytics

resource "azurerm_log_analytics_workspace" "this" {
  name                = "foundation-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_data_collection_rule" "linux_dcr" {
  name                = "linux-foundation-dcr"
  location            = var.location
  resource_group_name = var.resource_group_name

  destinations {
    log_analytics {
      name                  = "la-destination"
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
    }
  }

  data_flow {
    # Linux VM data
    streams      = ["Microsoft-Perf", "Microsoft-Syslog"]
    destinations = ["la-destination"]
  }

  data_sources {
    # 1. Performance Counters
    performance_counter {
      name                          = "perf-source"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "Processor(*)\\% Processor Time",       # CPU
        "Memory(*)\\% Used Memory",             # RAM
        "Logical Disk(*)\\% Free Space",        # Disco
        "Network Interface(*)\\Bytes Total/sec" # Rede
      ]
    }

    # 2. Syslog (Event viewer)
    syslog {
      name           = "syslog-source"
      streams        = ["Microsoft-Syslog"]
      facility_names = ["auth", "authpriv", "cron", "daemon", "kern", "syslog"]
      log_levels     = ["Error", "Warning", "Critical", "Alert", "Emergency"]
      # Podes adicionar "Info" ou "Debug" se quiseres muitos logs
    }
  }
}
resource "azurerm_monitor_action_group" "ag" {
  name                = "foundation-action-group"
  resource_group_name = var.resource_group_name
  short_name          = "foundationAG"

  email_receiver {
    name                    = "admin-email"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "high_cpu_alert" {
  name                = "high-cpu-linux-alert"
  resource_group_name = var.resource_group_name
  location            = var.location

  # Onde vamos procurar os dados? No Workspace!
  scopes = [azurerm_log_analytics_workspace.this.id]

  description          = "Alert when Linux VM CPU is over 80% for more than 5 minutes"
  severity             = 2
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  criteria {
    query = <<-QUERY
      Perf
      | where ObjectName == "Processor" and CounterName == "% Processor Time"
      | where InstanceName == "_Total"
      | summarize AggregatedValue = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
      | where AggregatedValue > 80
    QUERY

    # Configuração do Gatilho
    time_aggregation_method = "Average"
    operator                = "GreaterThan"
    threshold               = 80

    resource_id_column    = "Computer"
    metric_measure_column = "AggregatedValue"
    dimension {
      name     = "Computer"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.ag.id]
  }
}

# resource "azurerm_portal_dashboard" "apd_foundation_monitoring" {
#   name                = "apd-foundation-monitoring"
#   resource_group_name = var.resource_group_name
#   location            = var.location

#   dashboard_properties = file("${path.module}/dashboard/foundation-monitoring.json")

# }
