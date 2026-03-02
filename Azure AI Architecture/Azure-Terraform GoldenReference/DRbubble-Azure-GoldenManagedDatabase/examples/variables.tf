variable "subscription_id" {
  type        = string
  description = "subscription id for all resources in this module"
}

variable "sql_managed_database_name" {
    type        = string
    description = "The name of the SQL Managed Database."
}

variable "resource_group_name" {
  type        = string
  description = "group name for all resources."
}

variable "sql_managed_instance_name" {
  type        = string
  description = "The name of the SQL Managed Instance."
}

#################
###	 Backups 	###
#################

variable "short_term_retention_days" {
    type        = number
    description = "The backup retention period in days. This is how many days Point-in-Time Restore will be supported."
    default = 30
}
  
variable "immutable_backups_enabled" {
    type        = bool
    description = "immutable backups enabled"
    default     = false
}

variable "monthly_retention" {
    type        = string
    description = "The monthly retention policy for an LTR backup in an ISO 8601 format. Valid value is between 1 to 120 months."
    default     = "PT0S"
}

variable "week_of_year" {
    type        = string
    description = "The week of year to take the yearly backup. Value has to be between 1 and 52"
    default     = "PT0S"
}

variable "weekly_retention" {
    type        = string
    description = "The weekly retention policy for an LTR backup in an ISO 8601 format. Valid value is between 1 to 520 weeks."
    default     = "PT0S"
}

variable "yearly_retention" {
    type        = string
    description = "The yearly retention policy for an LTR backup in an ISO 8601 format. Valid value is between 1 to 10 years"
    default     = "PT0S"
}
  

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