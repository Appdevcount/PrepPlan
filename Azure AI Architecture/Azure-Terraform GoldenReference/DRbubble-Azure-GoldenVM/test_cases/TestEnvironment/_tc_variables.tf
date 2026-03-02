#Terraform variable declarations to support test cases

#Standard variables that appear in all modules
variable "location" {
  description = "Region to deploy to"
  type        = string
  default     = "EastUS"
}

variable "name" {
  description = "Name of application, will be used to build specific resource names"
  type        = string
}

/* Note, "required_tags" and "user_defined_tags" are combined into a single local variable "tags". 
   Reference the local variable when creating resources.                                            */

variable "required_tags" {
  description = "Required Cigna tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements)"
  type = object({
    AssetOwner       = string
    CostCenter       = string
    ServiceNowBA     = string
    ServiceNowAS     = string
    SecurityReviewID = string
  })
}

variable "required_data_tags" {
  description = "Required Cigna tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements)"
  type = object({
    DataSubjectArea        = string
    ComplianceDataCategory = string
    DataClassification     = string
    BusinessEntity         = string
    LineOfBusiness         = string
  })
}

variable "resource_group_name" {
  type = string
}

variable "VMs" {
  type = map(object({
    os_type          = string
    image_name       = string
    image_version_id = string
    size             = string
    admin_username   = string
    admin_password   = string
    data_disks = list(object({
      name                 = string
      disk_size_gb         = string
      storage_account_type = string
      lun                  = string
      caching              = string
    }))
    custom_data = string # Base64-Encoded Custom Data for this Virtual Machine, or null.
  }))
  description = "VMs to create"
}

variable "nics" {
  type = list(object({
    subnet_name          = string
    virtual_network_name = string
  }))
  description = "Nics to create. Name should be subnet name, value should be vNet subnet is in"
}

variable "nic_resource_group_name" {
  type        = string
  description = "Resource group to creat NICs in - if not specificed will default to resource group for VM."
  default     = "vmrg"
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

variable "private_ip_address_allocation" {
  type        = string
  description = "IP allocation (Dynamic or Static)"
  default     = "Dynamic"
}

variable "enable_accelerated_networking" {
  type        = bool
  description = "1 to turn accelerated networking on, 0 for off"
  default     = "1"
}

variable "OS_caching" {
  type        = string
  description = "Type of caching for OS disk - None, ReadOnly or ReadWrite"
  default     = "ReadWrite"
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

variable "zone" {
  type        = number
  description = "Availability zone to deploy VM to"
  default     = null
}

#Override
variable "storage_account_uri" {
  type        = string
  description = "URI pointing to root-level storage for diagnostics -- leave null to use Managed Storage account"
  default     = null
}
