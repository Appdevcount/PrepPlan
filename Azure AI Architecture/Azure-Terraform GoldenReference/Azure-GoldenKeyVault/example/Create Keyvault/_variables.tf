variable "resource_group_name" {
  description = "Resource group for this deployment"
  type        = string
}

variable "name" {
  description = "Name of the Key Vault. Used as a prefix for other resources."
  type        = string
}

variable "location" {
  description = "Location to deploy Key Vault in."
  type        = string 
}

variable "required_tags" {}

variable "optional_tags" {}

variable "keyvault_diagnostics_settings" {}

variable "private_endpoint_subnet_id" {
  type = string
  default = ""
}
variable "private_dns_zone_id" {
  type = string
  default = ""
}

variable "enable_purge_protection" {
  type        = bool
  description = "Boolean flag to enable purge protection."
  default     = true
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault."
  default     = false
}

variable "soft_delete_retention" {
  type        = number
  description = "Number of days that the Key Vault is held in a suspended state before being wiped. May need to be set higher for use with some services such as Event Hubs."
  default     = 7
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  default     = false
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the Key Vault."
  default     = false
}

variable "initial_access_assignments" {
  type = set(object({
    principal_id = string
    roles        = list(string)
    principal_type = string
  }))
  description = "Permissions (RBAC Roles or equivilant Access Policies) to apply when Key Vault is created."
  default     = []
}

variable "allowed_ip_rules" {
  type        = list(string)
  description = "IP Addresses allowed to access the Key Vault. This can be useful for Key Vaults used to encrypt terraform state where terraform is run from on premise."
  default = [
    "199.204.156.0/22",   # eviCore Express Route ATL
    "198.27.9.0/24" # eviCore Express Route DAL
  ]
}

variable "include_ado_cidrs" {
  type        = bool
  description = "Include ADO CIDRs when configuring ADO pipeline variable groups that require key vault access. (https://learn.microsoft.com/en-us/azure/devops/pipelines/process/set-secret-variables?view=azure-devops&tabs=yaml%2Cbash#link-secrets-from-an-azure-key-vault)"
  default     = false
}

variable "virtual_network_subnet_ids" {
  type        = list(string)
  description = "List of subnet ids allowed to connect securely and directly to Key Vault using service endpoints."
  default     = []
}

variable "public_network_access" {
  type        = bool
  description = "Allow public network access (Public IP) to this Key Vault."
  default     = true
}

variable "bypass_trusted_services" {
  type        = bool
  description = "Allow Azure trusted services to bypass the firewall."
  default     = false
}

variable "disk_encryption_sets" {
  type = map(object({
    #name of the key in Key Vault
    encryption_key = string
  }))
  description = "An optional mapping of disk_encryption_set names to disk_encryption_set configurations."
  default     = {}
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Use RBAC authentication for Key Vault -- this is the preferred method."
  default     = false
}

variable "sku_name" {
  type        = string
  description = "Provided as an over-ride feature, in case Key Vaults that require HSM protection are required."
  default     = "standard"
}

variable "tenant_id" {
  type        = string
  description = "ID of tenant Key Vault will use to authenticate requests -- provided as an over-ride in case deployment environment does not properly support client_config data source."
  default     = null
}
variable "keyvault_keys" {
  default = {}
}
