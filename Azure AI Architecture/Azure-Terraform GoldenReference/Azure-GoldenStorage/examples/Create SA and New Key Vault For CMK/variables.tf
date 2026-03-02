variable resource_group_name {}
variable location {}
variable name {}
variable account_kind {}
variable account_tier {}
variable account_replication_type {}
variable access_tier {}
variable "shared_access_key_enabled" {} 
variable sas_expiration_period_policy {
    type        = string
    default     = "00.06:00:00"  
}     
variable "default_to_oauth_authentication" {}
variable public_network_access_enabled {}
variable allowed_subnet_ids {
  description = "A list of resource ids for subnets"
  type        = list(string)
  default     = []
}
variable allowed_public_ips {
  description = "List of public IP or IP ranges in CIDR Format."
  type        = list(string)
  default = [
    "199.204.156.0/22",   # eviCore Express Route ATL
    "198.27.9.0/24" # eviCore Express Route DAL
  ]
}
variable network_rule_bypass {
  description = "A list of trusted Microsoft services to bypass the network rules. https://gsl.dome9.com/D9.AZU.NET.25.html"
  type        = list(string)
  default     =  ["AzureServices"]
}

variable "required_tags" {}
variable "optional_tags" {
  default = {}
}
variable "required_data_tags" {}
variable "optional_data_tags" {
  default = {}
}

variable "storage_diagnostics_settings" {}
variable "blob_diagnostics_settings" {}
variable "file_diagnostics_settings" {}
variable "queue_diagnostics_settings" {}
variable "table_diagnostics_settings" {}

##### STORAGE CONTAINER VARIABLES #####
variable "containers" {}
variable "files" {
  default = []
}
variable "tables" {
  default = []
}
variable "queues" {
  default = []
}

#Encryption
variable "infrastructure_encryption_enabled" {
  type    = bool
  default = true
}

# Identities
variable identity_type {
  description = ""
  type        = string
  default     = "SystemAssigned"
}
variable user_assigned_identity_ids {
  description = "List of principal ids that should have management rights over this keyvault - if none provided, it will default to the deploying identity"
  type        = list(string)
  default     = null
}

##### Private Endpoint variables ###
variable "private_endpoints" {
  default = []
}
variable "pe_subnet_id" {
  default = ""
}
