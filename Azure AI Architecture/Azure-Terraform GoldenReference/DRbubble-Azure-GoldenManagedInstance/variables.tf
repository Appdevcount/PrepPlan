variable "prefix" {
  type        = string
  description = "Prefix of the resource name"
}

###############
###	 Azure 	###
###############

variable "subscription_id" {
  type        = string
  description = "subscription id for all resources in this module"
}

variable "resource_group_name" {
  description = "name of the resource group to use for this deployment"
  type        = string
}

variable "resource_group_location" {
  description = "location of the resource group"
  type        = string
  default     = "East US"
}

variable "environment" {

  description = "Deployment environment."
  type        = string
  default     = "dev"
}

###########################
###	 Managed Instance 	###
###########################

variable "managed_instance_name" {
  type        = string
  description = "name to append to the prefix that names this managed instance. will be included in networking object names"
}

variable "location" {
  type        = string
  description = "Enter the location where you want to deploy the resources"
  default     = "eastus"
}

variable "sku_name" {
  type        = string
  description = "Enter SKU"
  default     = "GP_Gen5"
}

variable "license_type" {
  type        = string
  description = "Enter license type"
  default     = "BasePrice"
}

variable "vcores" {
  type        = number
  description = "Enter number of vCores you want to deploy"
  default     = 8
}

variable "storage_size_in_gb" {
  type        = number
  description = "Enter storage size in GB"
  default     = 32
}

variable "collation" {
  description = "SQL Server collation"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}


variable "managed_identity" {

  description = "Managed Identity for this instance"
  type        = string
}

###############
###	 VNET  	###
###############

variable "virtual_network_name" {
  description = "name of the previously created virtual network"
  type        = string
}

variable "instance_subnet_name" {
  description = "name of the subnet on which to create the managed instance. Should be part of the vi specified in virtual_network_name."
  type        = string
}

###############
###	 Entra 	###
###############
variable "entra_admin_username" {

  description = "Managed Identity or group to be the Entra administrator for this instance"
  type        = string
}

variable "entra_admin_object_id" {

  description = "Object ID of the Managed Identity or group to be the Entra administrator for this instance"
  type        = string
}

variable "entra_admin_principal_type" {

  description = "User or Group for the Entra ID admin type"
  type        = string
}

variable "tde_cmk_key_vault_name" {

  description = "Name of the key vault to store the tde cmks"
  type        = string
}

#############################
###	 Additional from AVM 	###
#############################

variable "dns_zone_partner_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the SQL Managed Instance which will share the DNS zone. This is a prerequisite for creating an `azurerm_sql_managed_instance_failover_group`. Setting this after creation forces a new resource to be created."
}

variable "maintenance_configuration_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Public Maintenance Configuration window to apply to the SQL Managed Instance. Valid values include `SQL_Default` or an Azure Location in the format `SQL_{Location}_MI_{Size}`(for example `SQL_EastUS_MI_1`). Defaults to `SQL_Default`."
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "(Optional) The Minimum TLS Version. Default value is `1.2` Valid values include `1.0`, `1.1`, `1.2`."
}

variable "proxy_override" {
  type        = string
  default     = null
  description = "(Optional) Specifies how the SQL Managed Instance will be accessed. Default value is `Default`. Valid values include `Default`, `Proxy`, and `Redirect`."
}

variable "public_data_endpoint_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Is the public data endpoint enabled? Default value is `false`."
}

variable "storage_account_type" {
  type        = string
  default     = "GZRS"
  description = "(Optional) Specifies the storage account type used to store backups for this database. Changing this forces a new resource to be created. Possible values are `GRS`, `LRS` and `ZRS`. Defaults to `GRS`."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
 - `create` - (Defaults to 24 hours) Used when creating the Microsoft SQL Managed Instance.
 - `delete` - (Defaults to 24 hours) Used when deleting the Microsoft SQL Managed Instance.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Microsoft SQL Managed Instance.
 - `update` - (Defaults to 24 hours) Used when updating the Microsoft SQL Managed Instance.
DESCRIPTION
}

variable "timezone_id" {
  type        = string
  default     = null
  description = "(Optional) The TimeZone ID that the SQL Managed Instance will be operating in. Default value is `UTC`. Changing this forces a new resource to be created."
}

variable "zone_redundant_enabled" {
  type        = bool
  default     = true
  description = "(Optional) If true, the SQL Managed Instance will be deployed with zone redundancy.  Defaults to `true`."
}

#####################
###	 DB Backups 	###
#####################

variable "immutable_backups_enabled" {
  type        = bool
  description = "enable/diable immutable backups"
  default     = false
}


variable "weekly_retention" {
  type        = string
  description = "Weekly Backup retention for managed instance databases"
  default     = "PT0S"
}


variable "yearly_retention" {
  type        = string
  description = "Yearly Backup retention for managed instance databases"
  default     = "PT0S"
}

variable "week_of_year" {
  type        = string
  description = "The week of year to take the yearly backup. Value has to be between 1 and 52."
  default     = 1
}

variable "monthly_retention" {
  type        = string
  description = "Monthly Backup retention for managed instance databases"
  default     = "PT0S"
}

#variable "short_term_retention_days" {
#  type        = number
#  description = "Backup retention for managed instance databases"
#  default     = 14
#}

#####################
###   Key Vault   ###
#####################

#variable "key_vault_name"{
#  type        = string
#  default     = null
#  description = "name for the admin keyvault to store the administrator password"
#}
#variable "private_enpoint_connection_name"{
#  type        = string
#  default     = null
#  description = "name of the private endpoint connection to connect to the keyvault"
#}

################
###   TAGS   ###
################

variable "required_tags" {
  description = "Required tags"
  type = object({
    AssetOwner             = string
    CostCenter             = string
    DataClassification     = string
    ServiceNowAS           = string
    SecurityReviewID       = string
    ServiceNowBA           = string
    LineOfBusiness         = string
    BusinessEntity         = string
    DataSubjectArea        = string
    ComplianceDataCategory = string
    P2P                    = string
  })
  # validation {
  #   condition     = var.required_tags.AssetOwner != "" && var.required_tags.CostCenter != "" && var.required_tags.ServiceNowBA != "" && var.required_tags.ServiceNowAS != "" && var.required_tags.SecurityReviewID != ""
  #   error_message = "Defining all tags is required for this resource"
  # }
}

variable "optional_tags" {
  description = "Optional user tags"
  type        = map(string)
  default     = {}
}
