variable name {
  type = string
}

variable location {
  type = string
  default = "eastus"
}

variable drlocation {
  type = string
  default = null
}

variable auto_inflate_enabled {
  type = bool
}

variable maximum_throughput_units {
  type = number
}

variable private_endpoints {
  type = bool
}

variable logging_enabled {
  type = bool
}

variable allowed_ip_ranges {
  type = list(string)
  default = []
}

variable namespace_shared_access_policies {
  type = map(object({
      send = bool
      listen = bool
    }))
  }

variable event_hubs {
  type = map(object({
    partition_count    = number
    message_retention  = number
    consumer_groups    = list(string)
    access_policies    = map(object({
      send    = bool
      listen  = bool
    }))
  }))
}

variable "required_tags" {
  type = object({
    AssetOwner       = string
    CostCenter       = string
    ServiceNowBA     = string
    ServiceNowAS     = string
    SecurityReviewID = string
  })
 }

variable subnetrules {
  description = "True if namespece subnet rules to be created, false if not -- rule will use subnet created as part of test setup"
  type = bool
}

variable logstorage {
  description = "True if logging should be to storage account (created as part of test setup)"
  type = bool
  default = false
}

variable loganalytics {
  description = "True if logging should be to analytics workspace (created as part of test setup)"
  type = bool
  default = false
}

variable logeh {
  description = "True if logging should be to event hub (created as part of test setup)"
  type = bool
  default = false
}
