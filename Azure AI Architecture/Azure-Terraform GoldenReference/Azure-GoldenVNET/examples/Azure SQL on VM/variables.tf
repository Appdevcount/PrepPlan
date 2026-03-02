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

# Networking
variable "AZ_SQL_VNET" {
  type                          = string
  description                   = "Which Virtual Network will the Azure SQL Managed Instance be deployed in"
}
variable "AZ_SQL_SUBNET" {
  type                          = string
  description                   = "Which Virtual Network Subnet will the Azure SQL Managed Instance be deployed in"
}

# Virtual Machine
variable "AZ_SQL_VMNAME" {
  type                        = string
  description                 = "Name of the Azure Windows VM to create"
}
variable "AZ_SQL_VMSIZE" {
  type                        = string
  description                 = "The SKU which should be used for this Virtual Machine, such as Standard_F2."
}
variable "AZ_SQL_VMSTORAGETYPE" {
  type                        = string
  description                 = "Storage account type for the VM's OS Disk"
}

# Backup Storage Account
variable "AZ_SQL_SA_BACKUP_NAME" {
  type                        = string
  description                 = "Name of Storage Account to use for SQL Backups"
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
variable "AZ_SQL_SP" {
  type                        = string
  description                 = "Name of service principal associated with the resource group"
}
variable "AZ_SQL_KV_KEYTYPE" {
  type        = string
  description = "Encryption algorithm for the Storage Account key"
}
variable "AZ_SQL_KV_KEYSIZE" {
  type        = number
  description = "Size of the Storage Account key to generate"
}

# SQL on VM
variable "AZ_SQL_LICENSE" {
  type                        = string
  description                 = "SQL License Type"
}
variable "AZ_SQL_PORT" {
  type                        = number
  description                 = "SQL TCP Port"
}
variable "AZ_SQL_CONNECTIVITYTYPE" {
  type                        = string
  description                 = "Connectivity type for the SQL Server"
}
variable "AZ_SQL_BACKUPENCRYPTENABLED" {
  type                        = bool
  description                 = "Enable or disable encryption for backups"
}
variable "AZ_SQL_BACKUPSYSTEMDATABASES" {
  type                        = bool
  description                 = "Enable or disable backup of system databases"
}
variable "AZ_SQL_BACKUPRETENTION" {
  type                        = number
  description                 = "Number of days to retain backups"
}
variable "AZ_SQL_PATCHDAY" {
  type                        = string
  description                 = "Day on which patches will be applied"
}
variable "AZ_SQL_MAINTWINDOWDURATION" {
  type                        = number
  description                 = "Number of minutes for the maintenance window"
}
variable "AZ_SQL_MAINTWINDOWSTARTHOUR" {
  type                        = number
  description                 = "Hour of the day at which maintenance window starts (0-23)"
}
