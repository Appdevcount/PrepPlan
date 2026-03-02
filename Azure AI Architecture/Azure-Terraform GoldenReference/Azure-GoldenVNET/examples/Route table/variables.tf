variable "application" {}
variable "rg_name" {}
variable "location" {}
variable "vnetcidr" {}
variable "subnets" {}
variable "production" {}
variable "required_tags" {}
variable "flow_storage_id" {}

/* Start
Route Enabling variables , default for below bool variables is false 
*/
variable allow_databricks_routes {}
variable allow_ms_egress_routes  {}
variable allow_apim_routes {}
variable allow_firewall_routes  {}
variable allow_sqlmi_routes {}

/* End */