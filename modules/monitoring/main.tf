
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
