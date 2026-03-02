name     = "evhns-standard-simple"
location = "eastus"

event_hubs = {
  messages = {
    partition_count   = 12
    message_retention = 5
    consumer_groups   = []
    access_policies   = {}
  }
}

required_tags = {
  AssetOwner       = "michael.schroeder@cigna.com"
  CostCenter       = "00047002"
  ServiceNowBA     = "n/a"
  ServiceNowAS     = "n/a"
  SecurityReviewID = "n/a"
}
