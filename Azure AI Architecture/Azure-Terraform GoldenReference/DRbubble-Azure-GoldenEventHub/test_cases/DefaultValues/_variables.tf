variable name {
  type = string
}

variable location {
  type = string
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
