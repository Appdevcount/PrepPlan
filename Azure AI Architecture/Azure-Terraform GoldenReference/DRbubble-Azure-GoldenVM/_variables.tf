#Standard variables that appear in all modules
variable "location" {
  description = "Region to deploy to"
  type        = string
  default     = "EastUS"
}

variable "resource_group_name" {
  description = "Resource group to deploy in"
  type        = string
}

variable "name" {
  description = "Name of <resource> to create"
  type        = string
}

/* Note, "required_tags" and "optional_tags" are combined into a single local variable "tags". 
   Reference the local variable when creating resources.                                            */

variable "required_tags" {
  description = "Required Cigna tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)"
  type = object({
    AssetOwner       = string
    CostCenter       = string
    ServiceNowBA     = string
    ServiceNowAS     = string
    SecurityReviewID = string
  })
  validation {
    condition     = var.required_tags.AssetOwner != "" && var.required_tags.CostCenter != "" && var.required_tags.ServiceNowBA != "" && var.required_tags.ServiceNowAS != "" && var.required_tags.SecurityReviewID != ""
    error_message = "Defining all tags is required for this resource (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)."
  }
}

variable "optional_tags" {
  description = "Optional Cigna standard tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)"
  type        = map(string)
  default     = {}
}

variable "required_data_tags" {
  description = "Required Cigna tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)"
  type = object({
    DataSubjectArea        = string
    ComplianceDataCategory = string
    DataClassification     = string
    BusinessEntity         = string
    LineOfBusiness         = string
  })
  validation {
    condition     = var.required_data_tags.DataSubjectArea != "" && var.required_data_tags.ComplianceDataCategory != "" && var.required_data_tags.DataClassification != "" && var.required_data_tags.BusinessEntity != "" && var.required_data_tags.LineOfBusiness != ""
    error_message = "Defining all data tags is required for this resource (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)."
  }
}

variable "optional_data_tags" {
  description = "Optional Cigna standard tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0)"
  type        = map(string)
  default     = {}
}


#Add additional variables as needed
#Variable name will typically match Terraform resource parameter name

#Variable file for Deploy Windows VM

variable "os_type" {
  type        = string
  description = "OS Type to deploy (Linux or Windows)"
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "Variable os_type must be either 'Linux' or 'Windows'."
  }
}
variable "nics" {
  type = list(object({
    subnet_name          = string
    virtual_network_name = string
  }))
  description = "Nics to create"
}

variable "nic_resource_group_name" {
  type        = string
  description = "Resource group to creat NICs in - if not specificed will default to resource group for VM."
  default     = "vmrg"
}

variable "image_name" {
  type        = string
  description = "Name of image in Shared Image Gallary"
  validation {
    condition = contains(["Ubuntu2004CIS", "Ubuntu2004CISstig", "WindowsServer2019", "WindowsServer2019Core"], var.image_name)
    error_message = "Must be a valid image name."
  }
}

variable "image_version_id" {
  type        = string
  description = "Version of image to deploy from Shared Image Gallery"
  default     = "latest"
}

variable "size" {
  type        = string
  description = "Select available VM size for region"
}
variable "OS_storage_account_type" {
  type        = string
  description = "OS Disk storage tier (Standard_LRS, StandardSSD_LRS, Premium_LRS)"
  default     = "StandardSSD_LRS"
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.OS_storage_account_type)
    error_message = "Variable OS_storage_account_type must be 'Standard_LRS', 'StandardSSD_LRS', or 'Premium_LRS'."
  }
}
variable "OS_disk_size_gb" {
  type        = number
  description = "OS Disk size in Gb"
  default     = 127
}
variable "data_disks" {
  type = list(object({
    name                 = string
    disk_size_gb         = string
    storage_account_type = string
    lun                  = string
    caching              = string
  }))
  description = "List of data disks to create for VM, leave empty for no data disks"
  default     = []
}
variable "admin_username" {
  type        = string
  description = "Administrator user name"
  sensitive   = true
}
variable "admin_password" {
  type        = string
  description = "Administrator password for Windows, or SSH key for Linux (pass in securely)"
  sensitive   = true
}
variable "OS_caching" {
  type        = string
  description = "Type of caching for OS disk - None, ReadOnly or ReadWrite"
  default     = "ReadWrite"
}
variable "custom_data" {
  type        = string
  description = "Base64-Encoded Custom Data for this Virtual Machine"
  default     = null
}
variable "priority" {
  type        = string
  description = "Set to Spot to enable VM as spot instance"
  default     = "Regular"
  validation {
    condition     = contains(["Regular", "Spot"], var.priority)
    error_message = "Variable priority must be either 'Regular' or 'Spot'."
  }
}
variable "ultra_ssd_enabled" {
  type        = bool
  description = "Set to true to enable Ultra SSD drive support"
  default     = false

}
variable "disk_encryption_set_id" {
  type        = string
  description = "ID of disk encryption set for SSE encryption"
}
variable "zone" {
  type        = number
  description = "Availability zone to deploy VM to"
  default     = null
}
variable "dedicated_host_id" {
  # V2 feature
  type        = string
  description = "ID of a Dedicated Host on which this machine should run"
  default     = null
}

#Override
variable "storage_account_uri" {
  type        = string
  description = "URI pointing to root-level storage for diagnostics -- leave null to use Managed Storage account"
  default     = null
}
variable "enable_automatic_updates" {
  type        = bool
  description = "If true automatically update OS"
  default     = "false"
}
variable "private_ip_address_allocation" {
  type        = string
  description = "IP allocation (Dynamic or Static)"
  default     = "Dynamic"
}
variable "enable_accelerated_networking" {
  type        = bool
  description = "Enable accelerated networking if true"
  default     = true
}
variable "encryption_at_host_enabled" {
  type        = bool
  description = "Enable Azure Encryption at Host"
  default     = true
}
