###############################################################################
#                                                                             #
# Azure SQL DB Golden Module - variables                                      #
#                                                                             #
###############################################################################

# Deployment Resource Group
variable "AZ_SQL_RSG" {
  type                          = string
  description                   = "Name of the Resource Group where the Azure SQL instances will be located."
}

# Key Vault
variable "AZ_KEYVAULT_NAME" {
  type        = string
  description = "Name of the credentials keyvault."
}
variable "AZ_SQL_SA_KV_ACCOUNT_NAME" {
  type                          = string
  description                   = "Name of secret username to assign as SA. Secret is stored in KeyVault identified by AZ_KEYVAULT_NAME."
}
variable "AZ_SQL_SA_KV_ACCOUNT_PASSWORD" {
  type                          = string
  description                   = "Name of secret password to assign as SA. Secret is stored in KeyVault identified by AZ_KEYVAULT_NAME."
}

# SIEM Logging Information
variable "AZ_PRODUCTION_SUBSCRIPTIONID" {
  type        = string
  description = "GUID identifying the subscription (Production) where the SIEM is located."
}
variable "AZ_TENANTID" {
  type        = string
  description = "GUID identifying the eviCore tenant."
}
variable "AZ_SIEM_SECURITY_RSG" {
  type                          = string
  description                   = "Name of the Resource Group where the SIEM is located."  
}
variable "AZ_SIEM_WORKSPACE_NAME" {
  type                          = string
  description                   = "Name of the SIEM Log Analytics workspace."  
}

# Tags
variable "AZ_SQL_TAGS" {}

# Azure SQL DB
variable "AZ_SQL_NAME" {
  type                          = string
  description                   = "Name of the SQL Azure Database to be created."
}
variable "AZ_SQL_VERSION" {
  type                          = string
  description                   = "Version of the SQL Azure Database to be created."
  default                       = "12.0"
}
variable "AZ_SQL_TLS_VERSION" {
  type                          = string
  description                   = "What is the minimum TLS version for the SQL Database connections."
  default                       = "1.2"

  validation {
    condition                   = contains(["1.0", "1.1", "1.2"], var.AZ_SQL_TLS_VERSION)
    error_message               = "Invalid TLS version; must be '1.0', '1.1' or '1.2'. NOTE: Anything less than '1.2' will violate Cigna/eviCore policy, and may not be able to be deployed."
  }
}
variable "AZ_SQL_CONNECTION_POLICY" {
  type                          = string
  description                   = "The connection policy the server will use."
  default                       = "Default"

  validation {
    condition                   = contains(["Default", "Proxy", "Redirect"], var.AZ_SQL_CONNECTION_POLICY)
    error_message               = "Invalid connection policy; must be 'Default', 'Proxy', or 'Redirect'."
  }
}
variable "AZ_SQL_PUBLIC_NETWORK_ACCESS" {
  type                          = bool
  description                   = "Whether public network access is allowed for this server."
  default                       = false

  validation {
    condition                   = contains([true, false], var.AZ_SQL_PUBLIC_NETWORK_ACCESS)
    error_message               = "Invalid public network access assignment; must be true or false."
  }
}
variable "AZ_SQL_AZURE_AD_AUTHENTICATION_ONLY" {
  type                          = bool
  description                   = "Whether public network access is allowed for this server."
  default                       = true

  validation {
    condition                   = contains([true, false], var.AZ_SQL_AZURE_AD_AUTHENTICATION_ONLY)
    error_message               = "Whether to only allow authentication via Azure AD."
  }
}
variable "AZ_SQL_SA_AAD_LOGIN" {
  type                          = string
  description                   = "Name of SQL login to be associated with the AAD Account. Must be different from the value identified by AZ_SQL_SA_KV_ACCOUNT_NAME."
}
variable "AZ_SQL_AZUREAD_ADMIN_OBJECT_ID" {
  type                          = string
  description                   = "Object ID of the Azure AD Administrator (user or group)."
}
variable "AZ_SQL_COLLATION" {
  type                          = string
  description                   = "SQL Server collation for the new database"
}
variable "AZ_SQL_LICENSE" {
  type                          = string
  description                   = "SQL Server license type"
}
variable "AZ_SQL_MAXSIZE" {
  type                          = string
  description                   = "Maximum size of SQL Database in GB"
}
variable "AZ_SQL_READSCALE" {
  type                          = bool
  description                   = "If enabled, connections that have application intent set to readonly in their connection string may be routed to a readonly secondary replica. This property is only settable for Premium and Business Critical databases."
  default                       = null
}
variable "AZ_SQL_SKU" {
  type                          = string
  description                   = "Azure SQL Database SKU"
}
variable "AZ_SQL_ZONEREDUNDANT" {
  type                          = bool
  description                   = "Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones. This property is only settable for Premium and Business Critical databases."
  default                       = null
}
variable "AZ_SQL_WEEKLY_RETENTION" {
  type                          = string
  description                   = "The weekly retention policy for an LTR backup in an ISO 8601 format. Valid value is between 1 to 520 weeks. e.g. P1Y, P1M, P1W or P7D."
}
variable "AZ_SQL_MONTHLY_RETENTION" {
  type                          = string
  description                   = "The monthly retention policy for an LTR backup in an ISO 8601 format. Valid value is between 1 to 120 months. e.g. P1Y, P1M, P4W or P30D."
}
variable "AZ_SQL_YEARLY_RETENTION" {
  type                          = string
  description                   = "The yearly retention policy for an LTR backup in an ISO 8601 format. Valid value is between 1 to 10 years. e.g. P1Y, P12M, P52W or P365D."
}

# Required, even if only weekly or monthly retention is selected
variable "AZ_SQL_WEEKOFYEAR" {
  type                          = number
  description                   = "The week of year to take the yearly backup. Value has to be between 1 and 52."
}

# Storage Account for Vuln Assessment
variable "AZ_SQL_SA_NAME" {
  type        = string
  description = "Name of Storage Account in which to save Vulnerability Assessment information."
}
variable "AZ_SQL_SA_TIER" {
  type        = string
  description = "Tier for storage account (Standard or Premium)."
  default     = "Standard"
}
variable "AZ_SQL_SA_REPLICATION" {
  type        = string
  description = "Replication type for storage account (LRS, GRS, RAGRS, ZRS, GZRS or RAGZRS)."
  default     = "Standard"
}

# Vulnerability Assessment
variable "AZ_SQL_VA_EMAILS" {
  type        = list(string)
  description = "List of emails to which Vulnerability Assessments should be sent"
}

# Private Endpoint
variable "AZ_SQL_PE_VNETNAME" {
  type        = string
  description = "The name of the VNET"
}
variable "AZ_SQL_PE_SUBNETNAME" {
  type        = string
  description = "The name of the subnet"
}
variable "AZ_SQL_PE_ZONENAME" {
  type        = string
  description = "DNS Zone Name"
}
variable "AZ_SQL_PE_PRIVATENAME" {
  type        = string
  description = "The private DNS name"
}
variable "AZ_SQL_PE_PRIVATEENDPOINTNAME" {
  type        = string
  description = "Name of the Private Endpoint"
}

# Customer-Managed Key Encryption
variable "AZ_SQL_KV_KEYTYPE" {
  type        = string
  description = "Encryption Key Type."
  default     = "RSA"
}
variable "AZ_SQL_KV_KEYSIZE" {
  type        = number
  description = "Encryption Key Size."
  default     = 2048
}