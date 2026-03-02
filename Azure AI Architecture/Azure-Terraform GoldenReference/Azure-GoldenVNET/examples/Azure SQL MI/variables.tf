###############################################################################
#                                                                             #
# Azure SQL Managed Instance Golden Module - variables                        #
#                                                                             #
###############################################################################

# Deployment Resource Group
variable "AZ_SQL_RSG" {
    type                        = string
    description                 = "Name of the Resource Group where the Azure SQL Managed Instance will be located."
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
variable "AZ_TENANTID" {
  type        = string
  description = "GUID identifying the eviCore tenant."
}
variable "AZ_PRODUCTION_SUBSCRIPTIONID" {
  type        = string
  description = "GUID identifying the subscription (Production) where the SIEM is located."
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

# Networking
variable "AZ_SQL_NSG" {
  type                          = string
  description                   = "Name of Network Security Group for Azure SQL Managed Instance."
}
variable "AZ_SQL_VNET" {
  type                          = string
  description                   = "Which Virtual Network will the Azure SQL Managed Instance be deployed in"
}
variable "AZ_SQL_SUBNET" {
  type                          = string
  description                   = "Which Virtual Network Subnet will the Azure SQL Managed Instance be deployed in"
}

# SQL Managed Instance
variable "AZ_SQL_NAME" {
    type                        = string
    description                 = "Name of Azure SQL Managed Instance to deploy"
}
variable "AZ_SQL_LICENSE_TYPE" {
  type                          = string
  description                   = "What type of license the Managed Instance will use"

  validation {
    condition                   = contains(["PriceIncluded", "BasePrice"], var.AZ_SQL_LICENSE_TYPE)
    error_message               = "Invalid license type; must be 'PriceIncluded' or 'BasePrice'."
  }
}
variable "AZ_SQL_SKU_NAME" {
  type                          = string
  description                   = "Which SKU of Azure SQL Managed Instance will be deployed"
}
variable "AZ_SQL_STORAGE_SIZE" {
  type                          = number
  description                   = "How much storage will be allocated to the Azure SQL Managed Instance (integer Gigabytes)"
}
variable "AZ_SQL_VCORES" {
  type                          = number
  description                   = "How many cores will be allocated to the Azure SQL Managed Instance (integer)"
}
variable "AZ_SQL_TLS_VERSION" {
  type                          = string
  description                   = "What is the minimum TLS version for the SQL Managed Instance connections."
  default                       = "1.2"

  validation {
    condition                   = contains(["1.0", "1.1", "1.2"], var.AZ_SQL_TLS_VERSION)
    error_message               = "Invalid TLS version; must be '1.0', '1.1' or '1.2'. NOTE: Anything less than '1.2' will violate Cigna/eviCore policy, and may not be able to be deployed."
  }
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
variable "AZ_SQL_SA_PUBLICACCESS" {
  type        = bool
  description = "Will the Vuln Assessment Storage Account have public access enabled"
}
variable "AZ_SQL_SA_CROSSTENANTREPL" {
  type        = bool
  description = "Will the Vuln Assessment Storage Account have cross-tenant replication enabled"
}
variable "AZ_SQL_KV_KEYTYPE" {
  type        = string
  description = "Encryption algorithm for the Storage Account key"
}
variable "AZ_SQL_KV_KEYSIZE" {
  type        = number
  description = "Size of the Storage Account key to generate"
}

# Vulnerability Assessment
variable "AZ_SQL_VA_TIER" {
  type        = string
  description = "Tier for the Vulnerability Assessment plan"
}
variable "AZ_SQL_VA_EMAILS" {
  type        = list(string)
  description = "List of emails to which Vulnerability Assessments should be sent"
}
