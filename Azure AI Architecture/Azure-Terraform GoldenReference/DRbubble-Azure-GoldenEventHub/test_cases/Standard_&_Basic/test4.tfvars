name                     = "evhns-standard-georedundant"
location                 = "eastus"
drlocation               = "westus"
private_endpoints        = true
auto_inflate_enabled     = true
maximum_throughput_units = 10
logging_enabled          = true
logeh                    = true

subnetrules       = true
allowed_ip_ranges = ["100.64.0.0/10", "10.188.0.0/16"]

event_hubs = {
  fe-messaging = {
    partition_count   = 30
    message_retention = 3
    consumer_groups   = ["iotios", "iotand", "feapps"]
    access_policies = {
      device_policy = {
        send   = true
        listen = false
      },
      app_policy = {
        send   = false
        listen = true
      }
    }
  },
  be-messaging = {
    partition_count   = 12
    message_retention = 5
    consumer_groups   = ["beapps"]
    access_policies   = {}
  },
  offloading = {
    partition_count   = 12
    message_retention = 5
    consumer_groups   = ["olgroup"]
    access_policies = {
      ol_policy = {
        send   = true
        listen = true
      }
    }
  }
}
namespace_shared_access_policies = {
  auditpol = {
    send   = true
    listen = true
  }
}
required_tags = {
  AssetOwner       = "michael.schroeder@cigna.com"
  CostCenter       = "00047002"
  ServiceNowBA     = "n/a"
  ServiceNowAS     = "n/a"
  SecurityReviewID = "n/a"
}
