variable "application" {}
variable "rg_name" {}
variable "location" {}
variable "environment" {}
variable "vnetcidr" {}
variable "subnets" {}
variable "vnet_suffix_name" {
    default = ""
}
variable "subnet_suffix_name" {
    default = ""
}

variable "production" {}
variable "required_tags" {}
#variable "flow_storage_id" {}
#variable "monitor_log_storage_account_id" {}
variable "allow_firewall_routes" {}

variable "storage_name" {}
variable "account_tier" {}
variable "account_kind" {}
variable "access_tier" {}
variable "identity_type" {}
variable "containers" {}
variable "account_replication_type" {}
variable "allow_nested_items_to_be_public" {}
variable "public_network_access_enabled" {}
variable "allowed_subnet_ids" {}
variable "shared_access_key_enabled" {}
variable "default_to_oauth_authentication" {}
variable "infrastructure_encryption_enabled" {}
variable "storage_diagnostics_settings" {}
variable "blob_diagnostics_settings" {}
variable "file_diagnostics_settings" {}
variable "queue_diagnostics_settings" {}
variable "table_diagnostics_settings" {}