name                     = "evhns-basic"
location                 = "eastus"
private_endpoints        = false
auto_inflate_enabled     = true
maximum_throughput_units = 10
logging_enabled          = true
logstorage               = true

subnetrules = false

event_hubs = {
  defaulthub = {
    partition_count   = 12
    message_retention = 1
    consumer_groups   = ["notallowed"]
    access_policies   = {}
  }
}

namespace_shared_access_policies = {}

required_tags = {
  AssetOwner       = "michael.schroeder@cigna.com"
  CostCenter       = "00047002"
  ServiceNowBA     = "n/a"
  ServiceNowAS     = "n/a"
  SecurityReviewID = "n/a"
}
