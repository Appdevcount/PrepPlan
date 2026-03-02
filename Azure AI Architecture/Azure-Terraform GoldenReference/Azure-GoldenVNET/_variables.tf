################################################################################
# VNet Variables
################################################################################

variable "application" {
  description = "The prefix used for all resources in this example"
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "The resource group to which all the network resources should be added"
}

variable "location" {
  description = "Region to deploy to"
  type        = string
  default     = "eastus2"
}

variable "location_abrv" {
  description = "(Optional if needed to be used in VNET name) The name of the location for the resource, such as eu, eu2, cus."
  type        = string
  default     = ""
}
variable "environment" {
  description = "(Optional if needed to be used in VNET name) The name of the environment for the resource, such as dev, test, prod."
  type        = string
  default     = ""
}

variable "vnetcidr" {
  description = "The CIDR(s) of the routable VNET"
  type        = list(string)

}

variable "dns_servers" {
  description = "Custom DNS server combinations for each environment"
  type        = map
  default = { 
    "595de295-db43-4c19-8b50-183dfd4a3d06" = {
      "nonprod" = {
        "eastus2" = ["10.193.0.54", "10.193.24.52", "10.210.60.61", "10.205.60.61"]
        "centralus" = ["10.193.24.52", "10.193.0.54", "10.210.60.61", "10.205.60.61"]
      }
      "prod" = {
        "eastus2" = ["10.194.46.52", "10.194.32.36", "10.210.60.61", "10.205.60.61"]
        "centralus" = ["10.194.32.36", "10.194.46.52", "10.210.60.61", "10.205.60.61"]
      }

    }
    "791b26cb-3fdf-47c3-b85d-bd9f037e3e7f" = {
      "nonprod" = {
        "eastus" = ["10.27.182.10", "10.44.12.10"]
        "eastus2" = ["10.27.182.10", "10.44.12.10"]
      }
      "prod" = {
        "eastus"    = ["10.27.182.10", "10.44.12.10"]
        "eastus2"   = ["10.27.182.10", "10.44.12.10"]
      }
    }

  }
}


/* # Subnets used with some services require their own network security group (NSG).
   # Set the 'managednsg' value to 'true' to prevent assignment of the default NSG.
   # By default this module will route traffic destined for the Internet through an Azure Firewall.
   # The firewall allows standard ports (https) outbound. If your application requires other ports to be opened, submit a detailed request in SNOW to the eviCore Cloud team.
   # This is important to ensure your workload will function properly after the upcoming Data Center migrations.
   # other services like databricks, apim, ase, sql managed instance ... require different route to different destination, to make sure those services work set the 'var.noroutetable_fw' to true and based on the service type
   # set the flage to true, currently in this module there are 3 more identified special route table, as follow:
 1. databricks route table, for databricks subnets, to assign subnet to this route table set routetable_databricks to true, and noroutetable_fw to true.
 2. apim route table, for for apim subnets, to assign subnet to this route table set routetable_apim to true, and noroutetable_fw to true.
 3. microsoft route table, some services require its traffic to be routed directly to microsoft internet like ase, and application gateway, to assign subnet to this route table set routetable_microsoft to true, and noroutetable_fw to true.
   # At least one service in Azure, SQL Managed Instance, is known to require its own route table, which not identified in this module to make sure this service work set noroutetable_fw to true.
for more details refer to https://evicorehealthcare.atlassian.net/wiki/spaces/~131354132/pages/770015359/Networking+Vnet+NSG+Route+Tables+etc.#Route-Tables-for-different-resources%27-subnets. */


variable "subnets" {
  description = "Map of subnets"
  type = map(object({
    address_prefixes                          = list(string)
    private_endpoint_network_policies_enabled = bool
    service_endpoints                         = optional(list(string))
    managednsg                                = bool
    routetable_firewall                       = bool
    routetable_sqlmi                          = optional(bool)
    routetable_apim                           = optional(bool)
    routetable_databricks                     = optional(bool)
    routetable_microsoft                      = optional(bool)
    delegation_name                           = optional(string)
    service_delegation_name                   = optional(string)
    service_delegation_actions                = optional(list(string))
  }))
  default = {
  }

  validation {
    condition     = length(var.subnets) > 0 ? alltrue([
                                                        for snet in var.subnets : alltrue([
                                                            for cidr in snet.address_prefixes : can(cidrnetmask(cidr))])
                                                      ]) : true
    error_message = "All subnets must be valid IPv4 CIDR block addresses."
    }   
}

/* example

  subnets                                               = {
    "eu2_dv1_snet_productname_private_endpoint"         = {
      address_prefixes                                  = ["10.193.100.0/28"]
      private_endpoint_network_policies_enabled         = false
      service_endpoints                                 = []
      managednsg                                        = false
      noroutetable_fw                                   = true

    }
    "eu2_dv1_snet_productname_databricks"               = {
      address_prefixes                                  = ["10.193.100.16/28"]
      private_endpoint_network_policies_enabled         = true
      service_endpoints                                 = ["Microsoft.Storage",]
      managednsg                                        = true
      noroutetable_fw                                   = true
      routetable_databricks                             = true

    }
    "eu2_dv1_snet_productname_vnet_integration"         = {
      address_prefixes                                  = ["10.193.100.32/28"]
      private_endpoint_network_policies_enabled         = true
      service_endpoints                                 = ["Microsoft.AzureCosmosDB",]
      managednsg                                        = false
      noroutetable_fw                                   = false

      delegation_name                                   = "appServiceDelegation"
      service_delegation_name                           = "Microsoft.Web/serverFarms"
      service_delegation_actions                        = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }

*/

variable "production" {
  description = "Production or non-production"
  type        = bool
  default     = false
}

variable "required_tags" {
  description = "Required tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+v2.0)."
  type = object({
    AssetOwner         = string
    CostCenter         = string
    ServiceNowBA     = string
    ServiceNowAS     = string
    SecurityReviewID = string
  })
  validation {
    condition     = var.required_tags.AssetOwner != "" && var.required_tags.CostCenter != "" && var.required_tags.ServiceNowBA != "" && var.required_tags.ServiceNowAS != "" && var.required_tags.SecurityReviewID != ""
    error_message = "Defining all tags is required for this resource (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+v2.0)."
  }
}

variable "optional_tags" {
  description = "Optional user tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+v2.0)."
  type        = map(string)
  default     = {}
}

variable "monitor_log_storage_account_id" {
  type        = string
  default     = null
  description = "The id for the storage account to which monitor logs should be sent."
}

variable "enable_diagnostics" {
  type    = bool
  default = false
}

variable "flow_storage_id" {
  type        = string
  description = "The id for the storage account to which NSG flow logs should be sent. Recommend using tfstate account."
  validation {
    condition = length(var.flow_storage_id) > 0 && var.flow_storage_id != null
    error_message = "flow_storage_id must not be empty or null"
  }
}

variable "firewall_ip_address" {
  description = "Azure firewall routing IP addresses"
  type        = map
  default = { 
    "595de295-db43-4c19-8b50-183dfd4a3d06" = {
      "nonprod" = {
        "eastus2"   = ""
        "centralus" = ""
      }
      "prod" = {
        "eastus2"   = "10.194.33.4"
        "centralus" = "10.194.46.132"
      }

    }
    "791b26cb-3fdf-47c3-b85d-bd9f037e3e7f" = {
      "nonprod" = {
        "eastus" = ""
        "eastus2" = ""
      }
      "prod" = {
        "eastus"    = ""
        "eastus2"   = ""
      }
    } 
  } 
}

variable "nonroutablevnetcidr" {
  description = "Allowed CIDR(s) for the non-routable VNET: 100.126.0.0/16 or 100.127.0.0/16 "
  type        = list(string)
  default = ["100.126.0.0/16"]
  
  validation {
  condition  = length(var.nonroutablevnetcidr) > 0 ? alltrue([
                                                                for cidr in var.nonroutablevnetcidr : contains(["100.126.0.0/16", "100.127.0.0/16"], cidr)
                                                             ]) : true
                                                         
  error_message = "All VNET CIDR blocks must be must be 100.126.0.0/16 or 100.127.0.0/16 or both."
  }  

}


variable "nonRoutableSubnets" {
  description = "Map of subnets"
  type = map(object({
    address_prefixes                          = list(string)
    private_endpoint_network_policies_enabled = bool
    service_endpoints                         = optional(list(string))
    managednsg                                = bool
    delegation_name                           = optional(string)
    service_delegation_name                   = optional(string)
    service_delegation_actions                = optional(list(string))
  }))
  default = {
  }

  validation {
    condition     = length(var.nonRoutableSubnets) > 0 ? alltrue([
                                                                   for snet in var.nonRoutableSubnets : alltrue([
                                                                    for cidr in snet.address_prefixes : can(cidrnetmask(cidr))])
                                                                 ]) : true
    error_message = "All subnets must be valid IPv4 CIDR block addresses."
    }  

}

variable "enable_nonroutable_peering" {
  description = "value"
  type        = bool
  default     = false
}
variable "dns_zone_name" {
  description = "Name of private dns zone to link VNet to"
  type        = string
  default     = ""
}

variable "dns_zone_rg" {
  description = "Resource group of private dns zone to link VNet to"
  type        = string
  default     = ""

}

variable "vnet_suffix_name" {
  description = "Optional: Suffix Name for VNet."
  type        = string
  default     = "-vnet"

  validation {
    condition = var.vnet_suffix_name != null
    error_message = "vnet_suffix_name must not be null. Empty string is allowed."
  }
}

variable "subnet_suffix_name" {
  description = "Optional: Suffix Name for Subnets."
  type        = string
  default     = "-subnet"

  validation {
    condition = var.subnet_suffix_name != null
    error_message = "subnet_suffix_name must not be null. Empty string is allowed."
  }
}

variable "nonroutable_vnet_suffix_name" {
  description = "Optional: Suffix name for NonRoutable VNet."
  type        = string
  default     = "-nonroutable-vnet"

  validation {
    condition = var.nonroutable_vnet_suffix_name != null
    error_message = "nonroutable_vnet_suffix_name must not be null. Empty string is allowed."
  }
}

variable "nonroutable_subnet_suffix_name" {
  description = "Optional: Suffix name for NonRoutable Subnets."
  type        = string
  default     = "-nonroutable-subnet"

  validation {
    condition = var.nonroutable_subnet_suffix_name != null
    error_message = "nonroutable_subnet_suffix_name must not be null. Empty string is allowed."
  }
}

variable "nsg_suffix_name" {
  description = "Optional: Suffix name for NSG."
  type        = string
  default     = "-nsg"

  validation {
    condition = var.nsg_suffix_name != null
    error_message = "nsg_suffix_name must not be null. Empty string is allowed."
  }
}
variable "nsg_nonroutable_suffix_name" {
  description = "Optional: Suffix name for NonRoutable NSG."
  type        = string
  default     = "-nonroutable-nsg"
  validation {
    condition = var.nsg_nonroutable_suffix_name != null
    error_message = "nsg_nonroutable_suffix_name must not be null. Empty string is allowed."
  }
}

variable "flow_log_suffix_name" {
  description = "Optional: Suffix name for flow logs."
  type        = string
  default     = "-flow-log"

  validation {
    condition = var.flow_log_suffix_name != null
    error_message = "flow_log_suffix_name must not be null. Empty string is allowed."
  }
}

variable "nonroutable_flow_log_suffix_name" {
  description = "Optional: Suffix name for nonroutable flow logs."
  type        = string
  default     = "-nonroutable-flow-log"

  validation {
    condition = var.nonroutable_flow_log_suffix_name != null
    error_message = "nonroutable_flow_log_suffix_name must not be null. Empty string is allowed."
  }
}

variable "routetable_suffix_name" {
  description = "Optional: Suffix name for all route tables."
  type        = string
  default     = "-default-internet-rt"

  validation {
    condition = var.routetable_suffix_name != null
    error_message = "routetable_suffix_name must not be null. Empty string is allowed."
  }
}
variable "routetable_databricks_suffix_name" {
  description = "Optional: Suffix name for databricks route tables."
  type        = string
  default     = "-databricks"

  validation {
    condition = var.routetable_databricks_suffix_name != null
    error_message = "routetable_databricks_suffix_name must not be null. Empty string is allowed."
  }
}
variable "routetable_apim_suffix_name" {
  description = "Optional: Suffix name for apim route tables."
  type        = string
  default     = "-apim"

  validation {
    condition = var.routetable_apim_suffix_name != null
    error_message = "routetable_apim_suffix_name must not be null. Empty string is allowed."
  }
}
variable "routetable_microsoft_suffix_name" {
  description = "Optional: Suffix name for microsoft route tables."
  type        = string
  default     = "-microsoft"

  validation {
    condition = var.routetable_microsoft_suffix_name != null
    error_message = "routetable_microsoft_suffix_name must not be null. Empty string is allowed."
  }
}

