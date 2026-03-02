variable name {
  type = string
  description = "Name to use as reference for the components created by this module"
}

variable resource_group_name {
  type = string
  description = "Name of the existing resource group that will house the components created by this module"
}

variable location {
  type = string
  description = "Azure location to deploy resources into"
}

variable artifact_root {
  type = string
  default = "https://artifactory.express-scripts.com/artifactory"
}

variable artifact_path {
  type = string
}

variable artifact {
  type = string
}

variable app_service_plan_id {
  type = string
  description = "Id of the app service plan that will be used by this function"
}

variable os_type {
  type = string
  description = "The OS type of the container resource."
  default = "windows"
}

variable app_settings {
  type = map(string)
  description = "Map of settings to be passed to function for environment configuration"
  default = {}
}

variable allowed_subnet_ids {
  type = list(string)
  description = "Subnet Ids for networks that require access to this storage account"
  default = null
}

variable required_tags {
  description = "Tags that are required per the version 2 tagging standards."
  type = object({
    SecurityReviewID = string
    AssetOwner       = string
    ServiceNowBA     = string
    CostCenter       = string
    ServiceNowAS     = string
  })
  validation {
    condition = var.required_tags.SecurityReviewID != "" && var.required_tags.AssetOwner != "" && var.required_tags.ServiceNowBA != "" && var.required_tags.CostCenter != "" && var.required_tags.ServiceNowAS != ""
    error_message = "Defining all tags is required for this resource (reference https://confluence.sys.cigna.com/pages/viewpage.action?spaceKey=CLOUD&title=Cloud+Tagging+Requirements+v2.0)."
  }
}

variable required_data_tags {
  description = "Tags that are required for data at rest per the version 2 tagging standards."
  type = object({
    DataSubjectArea        = string
    ComplianceDataCategory = string
    DataClassification     = string
    BusinessEntity         = string
    LineOfBusiness         = string
  })
  validation {
    condition = var.required_tags.DataSubjectArea != "" && var.required_tags.ComplianceDataCategory != "" && var.required_tags.DataClassification != "" && var.required_tags.BusinessEntity != "" && var.required_tags.LineOfBusiness != ""
    error_message = "Defining all tags is required for this resource (reference https://confluence.sys.cigna.com/pages/viewpage.action?spaceKey=CLOUD&title=Cloud+Tagging+Requirements+v2.0)."
  }
}

variable optional_tags {
  description = "Map of optional user defined tags for Azure resource."
  type        = map(string)
  default     = {}
}

variable optional_data_tags {
  description = "Map of optional user defined data tags for Azure resources."
  type        = map(string)
  default     = {}
}

variable sas_start_date {
  description = "SAS key start date for connection to function code storage account"
  type = string
  default = "2020-10-01"
}

variable sas_expiry_date {
  description = "SAS key expiration data for connection to function code storage account"
  type = string
  default = "2025-09-30"
}

variable monitor_log_storage_account_id {
  description = "Id for shared monitoring storage account id"
  type = string
}

variable worker_process_count {
  type = string
  description = "Number of process threads to allocate for the function on each worker"
  default = "1"
}

variable function_runtime {
  type = string
  description = "Runtime of the functions in the function app"
}

variable application_type {
  type = string
  description = "Application Type for Application Insights"
}

variable source_code_storage_source {
  type = string
  description = "Git repo for source code"
}

variable allowed_public_ids {
  type = list(string)
  description = "public IPs that require access to this storage account"
  default = null
}